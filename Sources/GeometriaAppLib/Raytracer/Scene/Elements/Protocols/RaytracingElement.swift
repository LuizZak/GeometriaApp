protocol RaytracingElement {
    func raycast(query: RayQuery) -> RayQuery
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory)
}
