#if canImport(Geometria)
import Geometria
#endif

public typealias GeometryRaytracingElement<T: Convex3Type> = GeometryElement<T> where T.Vector == RVector3D

extension GeometryRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
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
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        query.isFullyContained(by: geometry)
    }
}
