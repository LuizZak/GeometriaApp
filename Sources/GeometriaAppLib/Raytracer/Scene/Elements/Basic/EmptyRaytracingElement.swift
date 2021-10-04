struct EmptyRaytracingElement: RaytracingElement {
    @_transparent
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        partial
    }
}
