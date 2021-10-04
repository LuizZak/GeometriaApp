protocol RaymarchingElement: Element {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult
}
