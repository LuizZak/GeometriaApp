typealias DiskRaytracingElement = DiskElement

extension DiskRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        query.intersecting(id: id, material: material, plane: geometry)
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        query.intersectAll(
            id: id,
            material: material,
            plane: geometry,
            results: &results
        )
    }
    
    func fullyContainsRay(query: RayQuery) -> Bool {
        false // Planes cannot fully contain rays
    }
}
