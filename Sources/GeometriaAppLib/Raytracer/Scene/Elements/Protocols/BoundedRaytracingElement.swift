protocol BoundedRaytracingElement: RaytracingElement {
    /// Called to create the bounding box of this raytracing element.
    func makeBounds() -> RaytracingBounds
}
