protocol RaytracingElement: Element {
    func raycast(query: RayQuery) -> RayQuery
    func raycast(query: RayQuery, results: inout [RayHit])
}
