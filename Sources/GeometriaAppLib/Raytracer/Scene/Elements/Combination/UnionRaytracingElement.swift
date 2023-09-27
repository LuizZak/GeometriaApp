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

        var zipped = SortedRayHitsZipper(s0: t0Hits, s1: t1Hits)
        
        // Hit point criteria:
        // If outside T1 geometry: Collect T0 intersections
        // If outside T0 geometry: Collect T1 intersections
        // When crossing T1 geometry while within T0 geometry: Ignore intersections
        // When crossing T0 geometry while within T1 geometry: Ignore intersections

        var isInsideT0 = t0Hits.isEmpty ? false : t0Hits[0].hitDirection == .inside
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

                guard !query.ignoring.shouldIgnore(hit: rayHit, rayStart: query.ray.start) else {
                    break
                }

                if !isInsideT0 {
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
