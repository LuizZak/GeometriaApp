typealias CubeRaytracingElement = CubeElement

extension CubeRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        query.intersecting(id: id, material: material, geometry: geometry)
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        query.intersectAll(
            id: id,
            material: material,
            geometry: geometry,
            results: &results
        )
    }
}
