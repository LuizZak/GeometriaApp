public typealias EmptyRaytracingElement = EmptyElement

extension EmptyRaytracingElement: RaytracingElement {
    @_transparent
    public func raycast(query: consuming RayQuery) -> RayQuery {
        query
    }

    @_transparent
    public func raycast(query: RayQuery, results: inout [RayHit]) {
        
    }
    
    @inlinable
    public func fullyContainsRay(query: RayQuery) -> Bool {
        false
    }
}
