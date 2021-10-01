struct TupleRaymarchingElement2<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)

        return current
    }
}

struct TupleRaymarchingElement3<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1
    var t2: T2

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)

        return current
    }
}

struct TupleRaymarchingElement4<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)
        current = t2.signedDistance(to: point, current: current)
        current = t3.signedDistance(to: point, current: current)

        return current
    }
}

struct TupleRaymarchingElement5<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4

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

struct TupleRaymarchingElement6<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5

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

struct TupleRaymarchingElement7<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T6: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
    var t6: T6

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

struct TupleRaymarchingElement8<T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T6: RaymarchingElement, T7: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
    var t6: T6
    var t7: T7

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
