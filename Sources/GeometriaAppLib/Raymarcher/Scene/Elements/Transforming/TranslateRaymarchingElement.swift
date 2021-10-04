typealias TranslateRaymarchingElement<T: RaymarchingElement> = TranslateElement<T>

extension TranslateRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: point - translation, current: current)
    }
}
