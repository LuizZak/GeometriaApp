// Reference for distance function modifiers:
// https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
struct SmoothIntersectionElement<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1
    var smoothSize: Double

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let v0 = t0.signedDistance(to: point, current: current)
        let v1 = t1.signedDistance(to: point, current: current)
        
        let h = clamp(0.5 - 0.5 * (v0.distance - v1.distance) / smoothSize, min: 0.0, max: 1.0)
        let result = mix(v0, v1, factor: h).addingDistance(smoothSize * h * (1.0 - h))

        return min(current, result)
    }
}

@_transparent
func intersection<T0, T1>(smoothSize: Double, @RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> SmoothIntersectionElement<T0, T1> {
    let value = builder()
    return .init(t0: value.t0, t1: value.t1, smoothSize: smoothSize)
}
