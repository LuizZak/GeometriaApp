typealias ScaleRaytracingElement<T: RaytracingElement> = ScaleElement<T>

extension ScaleRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        let invScaling = 1 / scaling
        let scaledQuery = query.scaled(by: invScaling, around: scalingCenter)
        let scaledResult = element.raycast(query: scaledQuery)

        guard scaledQuery != scaledResult else {
            return query
        }

        return scaledResult.scaled(by: scaling, around: scalingCenter)
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        let invScaling = 1 / scaling
        let scaledQuery = query.scaled(by: invScaling, around: scalingCenter)

        return element.raycast(query: scaledQuery, results: &results)
    }
    
    func fullyContainsRay(query: RayQuery) -> Bool {
        let invScaling = 1 / scaling
        let scaledQuery = query.scaled(by: invScaling, around: scalingCenter)
        
        return element.fullyContainsRay(query: scaledQuery)
    }
}
