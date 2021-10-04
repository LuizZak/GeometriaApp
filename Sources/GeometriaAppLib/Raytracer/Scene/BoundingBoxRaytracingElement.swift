typealias BoundingBoxRaytracingElement<T: RaytracingElement> = 
    BoundingBoxElement<T>

extension BoundingBoxRaytracingElement: RaytracingElement {
    func raycast(query: RayQuery) -> RayQuery {
        guard intersects(query: query) else {
            return query
        }

        return element.raycast(query: query)
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        guard intersects(query: query) else {
            return
        }

        element.raycast(query: query, results: &results)
    }

    private func intersects(query: RayQuery) -> Bool {
        if let aabb = query.rayAABB, !boundingBox.intersects(aabb) {
            return false
        }

        return query.rayMagnitudeSquared.isFinite 
            ? boundingBox.intersects(line: query.lineSegment)
            : boundingBox.intersects(line: query.ray)
    }
}
