protocol RaytracingElement {
    func raycast(query: RayQuery) -> RayQuery
    func raycast(query: RayQuery, results: inout [RayHit])
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory)

    /// Returns an item on this raytracing element matching a specified id.
    /// Returns `nil` if no element with the given ID was found on this element
    /// or any of its sub-elements.
    func queryScene(id: Int) -> RaytracingElement?
}
