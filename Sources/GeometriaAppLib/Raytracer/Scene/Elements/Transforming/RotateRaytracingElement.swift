public typealias RotateRaytracingElement<T: RaytracingElement> = RotateElement<T>

extension RotateRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: RayQuery) -> RayQuery {
        let inv = rotation.mInv
        let queryT = query.rotatedBy(inv, around: rotationCenter)
        let resultT = element.raycast(query: queryT)

        guard queryT != resultT else {
            return query
        }

        return resultT.rotatedBy(rotation, around: rotationCenter)
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        let inv = rotation.mInv
        let queryT = query.rotatedBy(inv, around: rotationCenter)

        element.raycast(query: queryT, results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        let inv = rotation.mInv
        let queryT = query.rotatedBy(inv, around: rotationCenter)
        
        return element.fullyContainsRay(query: queryT)
    }
}
