typealias BoundingSphereRaytracingElement<T: RaytracingElement> = 
    BoundingSphereElement<T>

extension BoundingSphereRaytracingElement: RaytracingElement & BoundedRaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        guard intersects(query: query) else {
            return query
        }

        return element.raycast(query: query)
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        guard intersects(query: query) else {
            return
        }

        element.raycast(query: query, results: &results)
    }
    
    func fullyContainsRay(query: RayQuery) -> Bool {
        guard intersects(query: query) && query.isFullyContained(by: boundingSphere) else {
            return false
        }
        
        return element.fullyContainsRay(query: query)
    }

    @inlinable
    func intersects(query: RayQuery) -> Bool {
        query.rayMagnitudeSquared.isFinite 
            ? boundingSphere.intersects(line: query.lineSegment)
            : boundingSphere.intersects(line: query.ray)
    }
}
