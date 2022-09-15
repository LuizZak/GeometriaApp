typealias BoundingBoxRaytracingElement<T: RaytracingElement> = 
    BoundingBoxElement<T>

extension BoundingBoxRaytracingElement: RaytracingElement & RaytracingBoundedElement {
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
        guard intersects(query: query) && query.isFullyContained(by: boundingBox) else {
            return false
        }
        
        return element.fullyContainsRay(query: query)
    }

    @inlinable
    func intersects(query: RayQuery) -> Bool {
        if let aabb = query.rayAABB, !boundingBox.intersects(aabb) {
            return false
        }

        return query.rayMagnitudeSquared.isFinite 
            ? boundingBox.intersects(line: query.lineSegment)
            : boundingBox.intersects(line: query.ray)
    }
}
