typealias UnionRaymarchingElement<T0: RaymarchingElement, T1: RaymarchingElement> =
    UnionElement<T0, T1>

extension UnionRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)

        return current
    }
}