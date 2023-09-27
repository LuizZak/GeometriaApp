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
        
        // TODO: Optimize this step as we don't need to compute all intersections
        // TODO: to do this operation
        var local: SortedRayHits = []
        raycast(query: query, results: &local)

        if let hit = local.first, hit.point.distanceSquared(to: query.ray.start) < query.rayMagnitudeSquared {
            return query.withHit(hit)
        }

        return query
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        guard !query.ignoring.shouldIgnoreFully(id: id) else {
            return
        }
        
        var noHitQuery = query.withNilHit()
        noHitQuery.ignoring = .none

        var t0Hits: SortedRayHits = []
        t0.raycast(query: noHitQuery, results: &t0Hits)

        // If t0 is not intersected by the ray and does not fully contain it, it
        // means we are no longer within its bounds and thus there's no geometry
        // left to subtract.
        if t0Hits.isEmpty && !t0.fullyContainsRay(query: noHitQuery) {
            return
        }

        var t1Hits: SortedRayHits = []
        t1.raycast(query: noHitQuery, results: &t1Hits)

        var zipped = SortedRayHitsZipper(s0: t0Hits, s1: t1Hits)

        // Hit point criteria:
        // If outside T1 geometry: Collect all T0 intersections
        // When crossing T1 geometry while within T0 geometry: Invert hit direction and collect intersection
        // If inside T1 geometry: Ignore T0 intersections entirely
        // If outside T0 geometry: Ignore T1 intersections entirely

        var isInsideT0 = t0Hits[0].hitDirection == .inside
        var isInsideT1 = t1Hits.isEmpty ? false : t1Hits[0].hitDirection == .inside

        let newMaterial = material ?? t0Hits.first?.material ?? t1Hits.first?.material

        while let hit = zipped.next() {
            var rayHit = hit.rayHit
            rayHit.id = id
            rayHit.material = newMaterial

            switch hit {
            case .s0:
                isInsideT0 = rayHit.hitDirection == .outside

                guard !query.ignoring.shouldIgnore(hit: rayHit, rayStart: query.ray.start) else {
                    break
                }

                if !isInsideT1 {
                    results.insert(rayHit)
                }

            case .s1:
                isInsideT1 = rayHit.hitDirection == .outside

                let flipped = rayHit.withInvertedHitDirection

                guard !query.ignoring.shouldIgnore(hit: flipped, rayStart: query.ray.start) else {
                    break
                }

                // TODO: Add support for hollow subtracts which don't report intersections
                // with the subtracting geometry, leaving the model with a hole.
                if isInsideT0 {
                    results.insert(flipped)
                }
            }
        }
    }
    
    /// Performs a ray containment check on this subtraction raytracing element.
    ///
    /// Rays are fully contained by the subtracted geometry if they are fully
    /// contained by t0 (the base geometry) and do not intersect t1 (the geometry
    /// to subtract) at any point.
    public func fullyContainsRay(query: RayQuery) -> Bool {
        guard t0.fullyContainsRay(query: query) else {
            return false
        }

        if t1.raycast(query: query) != query {
            return false
        }

        return true
    }
}
