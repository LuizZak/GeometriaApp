public typealias PlaneRaytracingElement = PlaneElement

extension PlaneRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: RayQuery) -> RayQuery {
        query.intersecting(id: id, material: material, plane: geometry)
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout [RayHit]) {
        query.intersectAll(
            id: id,
            material: material,
            plane: geometry,
            results: &results
        )
    }
    
    public func fullyContainsRay(query: RayQuery) -> Bool {
        false // Planes cannot fully contain rays
    }
}
