protocol RaytracingElement {
    func raycast(query: RayQuery) -> RayQuery
    func raycast(query: RayQuery, results: inout [RayHit])
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory)
}
