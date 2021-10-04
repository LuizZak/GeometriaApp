typealias EmptyRaymarchingElement = EmptyElement

extension EmptyRaymarchingElement: RaymarchingElement {
    @_transparent
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        current
    }
}
