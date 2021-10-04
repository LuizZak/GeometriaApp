typealias TupleRaymarchingElement2<T0: RaymarchingElement, T1: RaymarchingElement> =
    TupleElement2<T0, T1>

typealias TupleRaymarchingElement3<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement> =
    TupleElement3<T0, T1, T2>

typealias TupleRaymarchingElement4<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement> =
    TupleElement4<T0, T1, T2, T3>

typealias TupleRaymarchingElement5<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement> =
    TupleElement5<T0, T1, T2, T3, T4>

typealias TupleRaymarchingElement6<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement> =
    TupleElement6<T0, T1, T2, T3, T4, T5>

typealias TupleRaymarchingElement7<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T6: RaymarchingElement> =
    TupleElement7<T0, T1, T2, T3, T4, T5, T6>

typealias TupleRaymarchingElement8<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T6: RaymarchingElement, T7: RaymarchingElement> =
    TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>

extension TupleRaymarchingElement2: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)

        return current
    }
}

extension TupleRaymarchingElement3: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)

        return current
    }
}

extension TupleRaymarchingElement4: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)

        return current
    }
}

extension TupleRaymarchingElement5: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)
        current = t4.signedDistance(to: point, current: current)

        return current
    }
}

extension TupleRaymarchingElement6: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)
        current = t4.signedDistance(to: point, current: current)
        current = t5.signedDistance(to: point, current: current)

        return current
    }
}

extension TupleRaymarchingElement7: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)
        current = t4.signedDistance(to: point, current: current)
        current = t5.signedDistance(to: point, current: current)
        current = t6.signedDistance(to: point, current: current)

        return current
    }
}

extension TupleRaymarchingElement8: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)
        current = t4.signedDistance(to: point, current: current)
        current = t5.signedDistance(to: point, current: current)
        current = t6.signedDistance(to: point, current: current)
        current = t7.signedDistance(to: point, current: current)

        return current
    }
}
