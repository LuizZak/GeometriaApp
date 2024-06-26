#if canImport(Geometria)
import Geometria
#endif

public typealias SubtractionRaytracingElement<T0: RaytracingElement, T1: RaytracingElement> =
    SubtractionElement<T0, T1>

extension SubtractionRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        guard !query.ignoring.shouldIgnoreFully(id: id) else {
            return query
        }

        /*
        let subQuery = (copy query).withRayIgnore(.none)
        let t0Query = t0.raycast(query: copy subQuery)
        let t1Query = t1.raycast(query: copy subQuery)
        let combined = SortedRayHitsZipper(s0Query: t0Query, s1Query: t1Query)
        var iterator = makeIterator(
            for: combined,
            query: query,
            isInsideT0: t0.contains(point: query.ray.start),
            isInsideT1: t1.contains(point: query.ray.start)
        )

        while let rayHit = iterator.next(), !query.ignoring.shouldIgnore(hit: rayHit) {
            return query.withHitIfCloser(rayHit)
        }
        // */

        //*
        // TODO: Optimize this step as we don't need to compute all intersections
        // TODO: to do this operation
        var local: SortedRayHits = []
        raycast(query: query, results: &local)

        if let hit = local.first {
            return query.withHitIfCloser(hit)
        }
        // */

        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        guard !query.ignoring.shouldIgnoreFully(id: id) else {
            return
        }
        
        let noIgnoreQuery = query.withRayIgnore(.none)

        var t0Hits: SortedRayHits = []
        t0.raycast(query: noIgnoreQuery, results: &t0Hits)

        // If t0 is not intersected by the ray and does not fully contain it, it
        // means we are no longer within its bounds and thus there's no geometry
        // left to subtract.
        if t0Hits.isEmpty && !t0.contains(point: noIgnoreQuery.ray.start) {
            return
        }

        var t1Hits: SortedRayHits = []
        t1.raycast(query: noIgnoreQuery, results: &t1Hits)

        let zipped = SortedRayHitsZipper(s0: t0Hits, s1: t1Hits)

        var iterator = makeIterator(
            for: zipped,
            query: query,
            isInsideT0: t0Hits.isEmpty || t0Hits[0].hitDirection == .fromInside,
            isInsideT1: !t1Hits.isEmpty && t1Hits[0].hitDirection == .fromInside
        )
        while let next = iterator.next() {
            results.insert(next)
        }
    }
    
    @inlinable
    public func contains(point: RVector3D) -> Bool {
        t0.contains(point: point) && !t1.contains(point: point)
    }
    
    // TODO: Handle ray containment when the ray crosses the boundaries of both geometries but stays within the overall volume of the subtraction
    /// Performs a ray containment check on this subtraction raytracing element.
    ///
    /// Rays are fully contained by the subtracted geometry if they are fully
    /// contained by t0 (the base geometry) and do not intersect t1 (the geometry
    /// to subtract) at any point.
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        guard t0.fullyContainsRay(query: query) else {
            return false
        }

        if t1.raycast(query: query) != query {
            return false
        }

        return true
    }

    @inlinable
    func makeIterator(
        for combined: SortedRayHitsZipper,
        query: RayQuery,
        isInsideT0: Bool,
        isInsideT1: Bool
    ) -> RayHitIterator {

        RayHitIterator(
            combined: combined,
            t0: t0,
            t1: t1,
            id: id,
            materialId: material,
            query: query,
            isInsideT0: isInsideT0,
            isInsideT1: isInsideT1
        )
    }

    @usableFromInline
    struct RayHitIterator: IteratorProtocol {
        @usableFromInline
        var combined: SortedRayHitsZipper
        @usableFromInline
        var isInsideT0: Bool
        @usableFromInline
        var isInsideT1: Bool

        @usableFromInline
        let newMaterial: MaterialId?
        @usableFromInline
        let id: Element.Id

        @usableFromInline
        let rayIgnore: RayIgnore

        @inlinable
        init(
            combined: SortedRayHitsZipper,
            t0: borrowing T0,
            t1: borrowing T1,
            id: Element.Id,
            materialId: MaterialId?,
            query: RayQuery,
            isInsideT0: Bool,
            isInsideT1: Bool
        ) {
            self.id = id
            self.combined = combined

            let t0Hits = combined.s0
            let t1Hits = combined.s1
            
            self.rayIgnore = query.ignoring
            self.isInsideT0 = isInsideT0
            self.isInsideT1 = isInsideT1
            
            //isInsideT0 = t0Hits.isEmpty || t0Hits[0].hitDirection == .fromInside
            //isInsideT1 = !t1Hits.isEmpty && t1Hits[0].hitDirection == .fromInside
            
            //isInsideT0 = t0Hits.isEmpty ? t0.contains(point: query.ray.start) : t0Hits[0].hitDirection == .fromInside
            //isInsideT1 = t1Hits.isEmpty ? t1.contains(point: query.ray.start) : t1Hits[0].hitDirection == .fromInside

            self.newMaterial = materialId ?? t0Hits.first?.material ?? t1Hits.first?.material
        }

        @inlinable
        mutating func next() -> RayHit? {
            // Hit point criteria:
            // If outside T1 geometry: Collect T0 intersections
            // If outside T0 geometry: Collect T1 intersections
            // When crossing T1 geometry while within T0 geometry: Ignore intersections
            // When crossing T0 geometry while within T1 geometry: Ignore intersections

            while let hit = combined.next() {
                var rayHit = hit.rayHit
                rayHit.id = id
                rayHit.material = newMaterial

                switch hit {
                case .s0:
                    isInsideT0 = rayHit.hitDirection == .fromOutside
                    
                    guard !rayIgnore.shouldIgnore(hit: rayHit) else {
                        break
                    }

                    if !isInsideT1 {
                        return rayHit
                    }

                case .s1:
                    isInsideT1 = rayHit.hitDirection == .fromOutside

                    let flipped = rayHit.withInvertedHitDirection

                    guard !rayIgnore.shouldIgnore(hit: flipped) else {
                        break
                    }

                    // TODO: Add support for hollow subtracts which don't report intersections
                    // with the subtracting geometry, leaving the model with a hole.
                    if isInsideT0 {
                        return flipped
                    }
                }
            }

            return nil
        }
    }
}
