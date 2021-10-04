struct ModuloRaymarchingElement<T: RaymarchingElement>: RaymarchingElement {
    var element: T
    var phase: RVector3D

    @_transparent
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: abs(point) % phase, current: current)
    }
}
