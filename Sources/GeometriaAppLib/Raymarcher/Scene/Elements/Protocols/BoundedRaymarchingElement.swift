protocol BoundedRaymarchingElement: RaymarchingElement {
    /// Called to create the bounding box of this raymarching element.
    func makeBounds() -> RaymarchingBounds
}
