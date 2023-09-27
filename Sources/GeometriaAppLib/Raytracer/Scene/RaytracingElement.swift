public protocol RaytracingElement: Element {
    func raycast(query: consuming RayQuery) -> RayQuery
    func raycast(query: RayQuery, results: inout SortedRayHits)
    
    // If this raytracing element is volumetric, returns whether the ray of the
    // given query is fully contained within its geometry.
    // For infinitely-spanning rays, only Hyperplane types can contain the ray.
    func fullyContainsRay(query: RayQuery) -> Bool
}
