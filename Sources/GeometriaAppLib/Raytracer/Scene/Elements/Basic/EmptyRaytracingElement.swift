struct EmptyRaytracingElement: RaytracingElement {
    @_transparent
    func raycast(query: RayQuery) -> RayQuery {
        query
    }

    @_transparent
    func raycast(query: RayQuery, results: inout [RayHit]) {
        
    }
    
    @_transparent
    func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        
    }

    @_transparent
    func queryScene(id: Int) -> RaytracingElement? {
        nil
    }
}
