struct IntersectionElement<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let v0 = t0.signedDistance(to: point, current: current)
        let v1 = t1.signedDistance(to: point, current: current)
        
        return max(v0, v1)
    }
}

extension IntersectionElement: BoundedRaymarchingElement where T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement {
    // TODO: Not ideal to create a bound out of the union here, but it's better
    // TODO: than not being bounded at all. Replace with .intersection() later?
    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds().union(t1.makeBounds())
    }
}
