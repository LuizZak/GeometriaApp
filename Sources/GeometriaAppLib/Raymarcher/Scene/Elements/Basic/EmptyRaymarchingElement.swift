typealias EmptyRaymarchingElement = EmptyElement

extension EmptyRaymarchingElement: RaymarchingElement {
    @_transparent
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        current
    }
}

extension EmptyRaymarchingElement: BoundedRaymarchingElement {
    @_transparent
    func makeRaymarchingBounds() -> RaymarchingBounds {
        .zero
    }
}
