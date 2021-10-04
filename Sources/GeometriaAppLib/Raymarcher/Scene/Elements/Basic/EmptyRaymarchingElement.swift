struct EmptyRaymarchingElement: BoundedRaymarchingElement {
    @_transparent
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        current
    }

    @_transparent
    func makeBounds() -> RaymarchingBounds {
        .zero
    }
}
