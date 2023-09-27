#if canImport(Geometria)
import Geometria
#endif

public typealias BoundingSphereRaytracingElement<T: RaytracingElement> = 
    BoundingSphereElement<T>

extension BoundingSphereRaytracingElement: RaytracingElement & RaytracingBoundedElement {
    @inlinable
    public func raycast(query: consuming RayQuery) -> RayQuery {
        guard intersects(query: query) else {
            return query
        }

        return element.raycast(query: query)
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        guard intersects(query: query) else {
            return
        }

        element.raycast(query: query, results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        guard intersects(query: query) && query.isFullyContained(by: boundingSphere) else {
            return false
        }
        
        return element.fullyContainsRay(query: query)
    }

    @inlinable
    public func intersects(query: RayQuery) -> Bool {
        query.rayMagnitudeSquared.isFinite 
            ? boundingSphere.intersects(line: query.lineSegment)
            : boundingSphere.intersects(line: query.ray)
    }
}
