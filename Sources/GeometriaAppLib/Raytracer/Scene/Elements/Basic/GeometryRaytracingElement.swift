typealias GeometryRaytracingElement<T: Convex3Type> = GeometryElement<T> where T.Vector == RVector3D

extension GeometryRaytracingElement: RaytracingElement {
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
