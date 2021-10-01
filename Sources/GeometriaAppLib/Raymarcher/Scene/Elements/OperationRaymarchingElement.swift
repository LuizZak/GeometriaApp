struct OperationRaymarchingElement<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1
    var operation: (RaymarchingResult, RaymarchingResult) -> RaymarchingResult

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let t0Result = t0.signedDistance(to: point, current: current)
        let t1Result = t1.signedDistance(to: point, current: current)

        return RaymarchingResult.union(current, operation(t0Result, t1Result))
    }
}
