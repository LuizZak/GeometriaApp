#if canImport(Geometria)
import Geometria
#endif

public typealias ScaleRaytracingElement<T: RaytracingElement> = ScaleElement<T>

extension ScaleRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: RayQuery) -> RayQuery {
        let inv = 1 / scaling
        let queryT = query.scaled(by: inv, around: scalingCenter)
        let resultT = element.raycast(query: queryT)

        guard queryT != resultT else {
            return query
        }

        return resultT.scaled(by: scaling, around: scalingCenter)
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        let inv = 1 / scaling
        let queryT = query.scaled(by: inv, around: scalingCenter)

        element.raycast(query: queryT, results: &results)
    }
    
    @inlinable
    public func contains(point: RVector3D) -> Bool {
        let inv = 1 / scaling
        let pointT = (point - scalingCenter) * inv + scalingCenter
        
        return element.contains(point: pointT)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        let inv = 1 / scaling
        let queryT = query.scaled(by: inv, around: scalingCenter)
        
        return element.fullyContainsRay(query: queryT)
    }
}
