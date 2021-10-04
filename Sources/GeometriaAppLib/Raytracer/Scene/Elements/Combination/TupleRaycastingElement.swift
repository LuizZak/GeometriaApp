struct TupleRaytracingElement2<T0: RaytracingElement, T1: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1

    @inlinable
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        var partial = partial
        
        partial = t0.raycast(partial: partial)
        partial = t1.raycast(partial: partial)
        
        return partial
    }
}

struct TupleRaytracingElement3<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2

    @inlinable
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        var partial = partial

        partial = t0.raycast(partial: partial)
        partial = t1.raycast(partial: partial)
        partial = t2.raycast(partial: partial)

        return partial
    }
}

struct TupleRaytracingElement4<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3

    @inlinable
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        var partial = partial

        partial = t0.raycast(partial: partial)
        partial = t1.raycast(partial: partial)
        partial = t2.raycast(partial: partial)
        partial = t3.raycast(partial: partial)

        return partial
    }
}

struct TupleRaytracingElement5<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4

    @inlinable
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        var partial = partial

        partial = t0.raycast(partial: partial)
        partial = t1.raycast(partial: partial)
        partial = t2.raycast(partial: partial)
        partial = t3.raycast(partial: partial)
        partial = t4.raycast(partial: partial)

        return partial
    }
}

struct TupleRaytracingElement6<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5

    @inlinable
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        var partial = partial

        partial = t0.raycast(partial: partial)
        partial = t1.raycast(partial: partial)
        partial = t2.raycast(partial: partial)
        partial = t3.raycast(partial: partial)
        partial = t4.raycast(partial: partial)
        partial = t5.raycast(partial: partial)

        return partial
    }
}

struct TupleRaytracingElement7<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement, T6: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
    var t6: T6

    @inlinable
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        var partial = partial

        partial = t0.raycast(partial: partial)
        partial = t1.raycast(partial: partial)
        partial = t2.raycast(partial: partial)
        partial = t3.raycast(partial: partial)
        partial = t4.raycast(partial: partial)
        partial = t5.raycast(partial: partial)
        partial = t6.raycast(partial: partial)

        return partial
    }
}

struct TupleRaytracingElement8<T0: RaytracingElement, T1: RaytracingElement, T2: RaytracingElement, T3: RaytracingElement, T4: RaytracingElement, T5: RaytracingElement, T6: RaytracingElement, T7: RaytracingElement>: RaytracingElement {
    var t0: T0
    var t1: T1
    var t2: T2
    var t3: T3
    var t4: T4
    var t5: T5
    var t6: T6
    var t7: T7

    @inlinable
    func raycast(partial: Scene.PartialRayResult) -> Scene.PartialRayResult {
        var partial = partial

        partial = t0.raycast(partial: partial)
        partial = t1.raycast(partial: partial)
        partial = t2.raycast(partial: partial)
        partial = t3.raycast(partial: partial)
        partial = t4.raycast(partial: partial)
        partial = t5.raycast(partial: partial)
        partial = t6.raycast(partial: partial)
        partial = t7.raycast(partial: partial)

        return partial
    }
}
