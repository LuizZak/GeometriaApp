public typealias EmptyRaytracingElement = EmptyElement

extension EmptyRaytracingElement: RaytracingElement {
    @_transparent
    public func raycast(query: RayQuery) -> RayQuery {
        query
    }

    @_transparent
    public func raycast(query: RayQuery, results: inout [RayHit]) {
        
    }
    
    public func fullyContainsRay(query: RayQuery) -> Bool {
        false
    }
}
