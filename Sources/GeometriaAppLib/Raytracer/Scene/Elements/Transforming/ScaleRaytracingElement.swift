typealias ScaleRaytracingElement<T: RaytracingElement> = ScaleElement<T>

extension ScaleRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        let inv = 1 / scaling
        let queryT = query.scaled(by: inv, around: scalingCenter)
        let resultT = element.raycast(query: queryT)

        guard queryT != resultT else {
            return query
        }

        return resultT.scaled(by: scaling, around: scalingCenter)
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        let inv = 1 / scaling
        let queryT = query.scaled(by: inv, around: scalingCenter)

        element.raycast(query: queryT, results: &results)
    }
    
    func fullyContainsRay(query: RayQuery) -> Bool {
        let inv = 1 / scaling
        let queryT = query.scaled(by: inv, around: scalingCenter)
        
        return element.fullyContainsRay(query: queryT)
    }
}
