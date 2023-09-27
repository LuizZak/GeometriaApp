#if canImport(Geometria)
import Geometria
#endif

public typealias IntersectionRaytracingElement<T0: RaytracingElement, T1: RaytracingElement> =
    IntersectionElement<T0, T1>

extension IntersectionRaytracingElement: RaytracingElement {
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
        var t1Hits: SortedRayHits = []
        t0.raycast(query: noHitQuery, results: &t0Hits)
        t1.raycast(query: noHitQuery, results: &t1Hits)
        
        // Skip fully empty hits
        if t0Hits.isEmpty && t1Hits.isEmpty {
            return
        }
        
        // Must have at least one hit of (or be fully contained by) each geometry
        // type to be able to form an intersection geometry
        if (t0Hits.isEmpty && !t0.fullyContainsRay(query: noHitQuery)) ||
            (t1Hits.isEmpty && !t1.fullyContainsRay(query: noHitQuery))
        {
            return
        }

        // TODO: Attempt to perform the intersection boolean logic without first combining all hit points into one list; the combined list is discarded after the work is done and leads to unnecessary memory allocations.
        var zipped = SortedRayHitsZipper(s0: t0Hits, s1: t1Hits)
        
        // Hit point criteria:
        // If outside T1 geometry: Ignore all intersections
        // If outside T0 geometry: Ignore all intersections
        // When crossing T1 geometry while within T0 geometry: Collect intersection
        // When crossing T0 geometry while within T1 geometry: Collect intersection

        var isInsideT0 = t0Hits.isEmpty || t0Hits[0].hitDirection == .inside
        var isInsideT1 = t1Hits.isEmpty || t1Hits[0].hitDirection == .inside

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

                if isInsideT1 {
                    results.insert(rayHit)
                }

            case .s1:
                isInsideT1 = rayHit.hitDirection == .outside

                guard !query.ignoring.shouldIgnore(hit: rayHit, rayStart: query.ray.start) else {
                    break
                }

                if isInsideT0 {
                    results.insert(rayHit)
                }
            }
        }
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        t0.fullyContainsRay(query: query) && t1.fullyContainsRay(query: query)
    }
}
