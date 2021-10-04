// Reference for distance function modifiers:
// https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
struct IntersectionElement<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let v0 = t0.signedDistance(to: point, current: current)
        let v1 = t1.signedDistance(to: point, current: current)
        
        return max(v0, v1)
    }
}

extension IntersectionElement: BoundedRaymarchingElement where T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement {
    // TODO: Not ideal to create a bound out of the union here, but it's better
    // TODO: than not being bounded at all. Replace with .intersection() later?
    func makeRaymarchingBounds() -> RaymarchingBounds {
        t0.makeRaymarchingBounds().union(t1.makeRaymarchingBounds())
    }
}

@_transparent
func intersection<T0, T1>(@RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> IntersectionElement<T0, T1> {
    let value = builder()

    return .init(t0: value.t0, t1: value.t1)
}
