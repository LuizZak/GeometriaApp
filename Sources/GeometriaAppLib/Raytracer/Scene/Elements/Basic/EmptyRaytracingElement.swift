typealias EmptyRaytracingElement = EmptyElement

extension EmptyRaytracingElement: RaytracingElement {
    @_transparent
    func raycast(query: RayQuery) -> RayQuery {
        query
    }

    @_transparent
    func raycast(query: RayQuery, results: inout [RayHit]) {
        
    }
    
    func fullyContainsRay(query: RayQuery) -> Bool {
        false
    }
}
