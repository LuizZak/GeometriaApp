struct EmptyRaytracingElement: RaytracingElement {
    @_transparent
    func raycast(query: RayQuery) -> RayQuery {
        query
    }
    
    @_transparent
    func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        
    }
}
