typealias TupleRaymarchingElement2<T0, T1> =
    TupleElement2<T0, T1> where
        T0: RaymarchingElement,
        T1: RaymarchingElement

typealias TupleRaymarchingElement3<T0, T1, T2> =
    TupleElement3<T0, T1, T2> where
        T0: RaymarchingElement,
        T1: RaymarchingElement,
        T2: RaymarchingElement

typealias TupleRaymarchingElement4<T0, T1, T2, T3> =
    TupleElement4<T0, T1, T2, T3> where
        T0: RaymarchingElement,
        T1: RaymarchingElement,
        T2: RaymarchingElement,
        T3: RaymarchingElement

typealias TupleRaymarchingElement5<T0, T1, T2, T3, T4> =
    TupleElement5<T0, T1, T2, T3, T4> where
        T0: RaymarchingElement,
        T1: RaymarchingElement,
        T2: RaymarchingElement,
        T3: RaymarchingElement,
        T4: RaymarchingElement

typealias TupleRaymarchingElement6<T0, T1, T2, T3, T4, T5> =
    TupleElement6<T0, T1, T2, T3, T4, T5> where
        T0: RaymarchingElement,
        T1: RaymarchingElement,
        T2: RaymarchingElement,
        T3: RaymarchingElement,
        T4: RaymarchingElement,
        T5: RaymarchingElement

typealias TupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6> =
    TupleElement7<T0, T1, T2, T3, T4, T5, T6> where
        T0: RaymarchingElement,
        T1: RaymarchingElement,
        T2: RaymarchingElement,
        T3: RaymarchingElement,
        T4: RaymarchingElement,
        T5: RaymarchingElement,
        T6: RaymarchingElement

typealias TupleRaymarchingElement8<T0, T1, T2, T3, T4, T5, T6, T7> =
    TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7> where
        T0: RaymarchingElement,
        T1: RaymarchingElement,
        T2: RaymarchingElement,
        T3: RaymarchingElement,
        T4: RaymarchingElement,
        T5: RaymarchingElement,
        T6: RaymarchingElement,
        T7: RaymarchingElement

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
