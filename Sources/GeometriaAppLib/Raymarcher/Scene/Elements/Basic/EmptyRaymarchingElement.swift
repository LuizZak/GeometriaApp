struct EmptyRaymarchingElement: RaymarchingElement {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        current
    }
}
