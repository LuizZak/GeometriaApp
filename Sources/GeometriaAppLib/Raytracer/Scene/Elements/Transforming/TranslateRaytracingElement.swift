typealias TranslateRaytracingElement<T: RaytracingElement> = TranslateElement<T>

extension TranslateRaytracingElement: RaytracingElement {
    @inlinable
    func raycast(query: RayQuery) -> RayQuery {
        let offsetQuery = query.translated(by: -translation)

        let offsetResult = element.raycast(query: offsetQuery)

        guard offsetQuery != offsetResult else {
            return query
        }

        return offsetResult.translated(by: translation)
    }

    @inlinable
    func raycast(query: RayQuery, results: inout [RayHit]) {
        element.raycast(query: query.translated(by: -translation), results: &results)
    }
    
    func fullyContainsRay(query: RayQuery) -> Bool {
        let offsetQuery = query.translated(by: -translation)
        
        return element.fullyContainsRay(query: offsetQuery)
    }
}
