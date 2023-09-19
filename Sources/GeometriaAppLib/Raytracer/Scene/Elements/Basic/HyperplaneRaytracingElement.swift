#if canImport(Geometria)
import Geometria
#endif

public typealias HyperplaneRaytracingElement = HyperplaneElement

extension HyperplaneRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: RayQuery) -> RayQuery {
        query.intersecting(id: id, material: material, convex: geometry)
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout [RayHit]) {
        query.intersectAll(
            id: id,
            material: material,
            convex: geometry,
            results: &results
        )
    }
    
    public func fullyContainsRay(query: RayQuery) -> Bool {
        query.isFullyContained(by: geometry)
    }
}
