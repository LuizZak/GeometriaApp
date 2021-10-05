typealias BoundingSphereRaytracingElement<T: RaytracingElement> = 
    BoundingSphereElement<T>

extension BoundingSphereRaytracingElement: RaytracingElement {
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

    @inlinable
    func intersects(query: RayQuery) -> Bool {
        query.rayMagnitudeSquared.isFinite 
            ? boundingSphere.intersects(line: query.lineSegment)
            : boundingSphere.intersects(line: query.ray)
    }
}
