#if canImport(Geometria)
import Geometria
#endif

public typealias TranslateRaytracingElement<T: RaytracingElement> = TranslateElement<T>

extension TranslateRaytracingElement: RaytracingElement {
    @inlinable
    public func raycast(query: RayQuery) -> RayQuery {
        let offsetQuery = query.translated(by: -translation)

        let offsetResult = element.raycast(query: offsetQuery)

        guard offsetQuery != offsetResult else {
            return query
        }

        return offsetResult.translated(by: translation)
    }

    @inlinable
    public func raycast(query: RayQuery, results: inout SortedRayHits) {
        element.raycast(query: query.translated(by: -translation), results: &results)
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        let offsetQuery = query.translated(by: -translation)
        
        return element.fullyContainsRay(query: offsetQuery)
    }
}
