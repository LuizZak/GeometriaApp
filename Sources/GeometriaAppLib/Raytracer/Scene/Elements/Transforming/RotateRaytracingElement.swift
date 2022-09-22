typealias RotateRaytracingElement<T: RaytracingElement> = RotateElement<T>

extension RotateRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        let inv = rotation.mInv
        let queryT = query.rotated(by: inv, around: rotationCenter)
        let resultT = element.raycast(query: queryT)

        guard queryT != resultT else {
            return query
        }

        return resultT.rotated(by: rotation, around: rotationCenter)
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        let inv = rotation.mInv
        let queryT = query.rotated(by: inv, around: rotationCenter)

        element.raycast(query: queryT, results: &results)
    }
    
    func fullyContainsRay(query: RayQuery) -> Bool {
        let inv = rotation.mInv
        let queryT = query.rotated(by: inv, around: rotationCenter)
        
        return element.fullyContainsRay(query: queryT)
    }
}
