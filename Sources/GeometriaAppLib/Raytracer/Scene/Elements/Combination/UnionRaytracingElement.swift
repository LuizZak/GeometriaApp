#if canImport(Geometria)
import Geometria
#endif

public typealias UnionRaytracingElement<T0: RaytracingElement, T1: RaytracingElement> =
    UnionElement<T0, T1>

extension UnionRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        guard !query.ignoring.shouldIgnoreFully(id: id) else {
            return query
        }

        /*
        let subQuery = (copy query).withNilHit().withRayIgnore(.none)
        let t0Query = t0.raycast(query: copy subQuery)
        let t1Query = t1.raycast(query: copy subQuery)
        let combined = SortedRayHitsZipper(s0Query: t0Query, s1Query: t1Query)
        var iterator = makeIterator(for: combined, query: subQuery)

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
        var t1Hits: SortedRayHits = []
        t0.raycast(query: noIgnoreQuery, results: &t0Hits)
        t1.raycast(query: noIgnoreQuery, results: &t1Hits)

        let zipped = SortedRayHitsZipper(s0: t0Hits, s1: t1Hits)

        var iterator = makeIterator(for: zipped, query: query)
        while let next = iterator.next() {
            results.insert(next)
        }
    }
    
    @inlinable
    public func contains(point: RVector3D) -> Bool {
        return t0.contains(point: point) || t1.contains(point: point)
    }
    
    // TODO: Handle ray containment when the ray crosses the boundaries of both geometries but stays within the overall volume of the union
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        t0.fullyContainsRay(query: query) || t1.fullyContainsRay(query: query)
    }

    @inlinable
    func makeIterator(for combined: SortedRayHitsZipper, query: RayQuery) -> RayHitIterator {
        RayHitIterator(
            combined: combined,
            t0: t0,
            t1: t1,
            id: id,
            materialId: material,
            query: query
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
            t0: T0,
            t1: T1,
            id: Element.Id,
            materialId: MaterialId?,
            query: RayQuery
        ) {
            self.id = id
            self.combined = combined

            let t0Hits = combined.s0
            let t1Hits = combined.s1
            
            isInsideT0 = t0Hits.isEmpty ? false : t0Hits[0].hitDirection == .fromInside
            isInsideT1 = t1Hits.isEmpty ? false : t1Hits[0].hitDirection == .fromInside

            self.newMaterial = materialId ?? t0Hits.first?.material ?? t1Hits.first?.material
            self.rayIgnore = query.ignoring
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
                    
                    guard !rayIgnore.shouldIgnore(hit: rayHit) else {
                        break
                    }

                    if !isInsideT0 {
                        return rayHit
                    }
                }
            }

            return nil
        }
    }
}
