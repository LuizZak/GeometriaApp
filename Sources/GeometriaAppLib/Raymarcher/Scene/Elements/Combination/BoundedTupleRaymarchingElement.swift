struct BoundedTupleRaymarchingElement2<T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement>: BoundedRaymarchingElement {
    var t0: T0
    var t1: T1
    
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        current = t0.signedDistance(to: point, current: current)
        current = t1.signedDistance(to: point, current: current)

        return current
    }

    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds().union(t1.makeBounds())
    }
}

struct BoundedTupleRaymarchingElement3<T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement, T2: BoundedRaymarchingElement>: BoundedRaymarchingElement {
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

    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds().union(t1.makeBounds()).union(t2.makeBounds())
    }
}

struct BoundedTupleRaymarchingElement4<T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement, T2: BoundedRaymarchingElement, T3: BoundedRaymarchingElement>: BoundedRaymarchingElement {
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

    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds().union(t1.makeBounds()).union(t2.makeBounds()).union(t3.makeBounds())
    }
}

struct BoundedTupleRaymarchingElement5<T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement, T2: BoundedRaymarchingElement, T3: BoundedRaymarchingElement, T4: BoundedRaymarchingElement>: BoundedRaymarchingElement {
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

    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds().union(t1.makeBounds()).union(t2.makeBounds()).union(t3.makeBounds()).union(t4.makeBounds())
    }
}

struct BoundedTupleRaymarchingElement6<T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement, T2: BoundedRaymarchingElement, T3: BoundedRaymarchingElement, T4: BoundedRaymarchingElement, T5: BoundedRaymarchingElement>: BoundedRaymarchingElement {
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

    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds().union(t1.makeBounds()).union(t2.makeBounds()).union(t3.makeBounds()).union(t4.makeBounds()).union(t5.makeBounds())
    }
}

struct BoundedTupleRaymarchingElement7<T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement, T2: BoundedRaymarchingElement, T3: BoundedRaymarchingElement, T4: BoundedRaymarchingElement, T5: BoundedRaymarchingElement, T6: BoundedRaymarchingElement>: BoundedRaymarchingElement {
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

    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds().union(t1.makeBounds()).union(t2.makeBounds()).union(t3.makeBounds()).union(t4.makeBounds()).union(t5.makeBounds()).union(t6.makeBounds())
    }
}

struct BoundedTupleRaymarchingElement8<T0: BoundedRaymarchingElement, T1: BoundedRaymarchingElement, T2: BoundedRaymarchingElement, T3: BoundedRaymarchingElement, T4: BoundedRaymarchingElement, T5: BoundedRaymarchingElement, T6: BoundedRaymarchingElement, T7: BoundedRaymarchingElement>: BoundedRaymarchingElement {
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

    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds().union(t1.makeBounds()).union(t2.makeBounds()).union(t3.makeBounds()).union(t4.makeBounds()).union(t5.makeBounds()).union(t6.makeBounds()).union(t7.makeBounds())
    }
}
