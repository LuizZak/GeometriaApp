public protocol RaytracingElement: Element {
    func raycast(query: consuming RayQuery) -> RayQuery
    func raycast(query: RayQuery, results: inout SortedRayHits)

    /// Returns `true` if this point is contained within any geometry in this
    /// raytracing element or one of its sub-elements. Containment check is done
    /// against full geometries and not just bounding boxes.
    func contains(point: RVector3D) -> Bool
    
    // If this raytracing element is volumetric, returns whether the ray of the
    // given query is fully contained within its geometry.
    // For infinitely-spanning rays, only Hyperplane types can contain the ray.
    func fullyContainsRay(query: RayQuery) -> Bool
}
