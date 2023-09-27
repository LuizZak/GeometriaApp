#if canImport(Geometria)
import Geometria
#endif

public typealias PlaneRaytracingElement = PlaneElement

extension PlaneRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        query.intersecting(id: id, material: material, plane: geometry)
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        query.intersectAll(
            id: id,
            material: material,
            plane: geometry,
            results: &results
        )
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        false // Planes cannot fully contain rays
    }
}
