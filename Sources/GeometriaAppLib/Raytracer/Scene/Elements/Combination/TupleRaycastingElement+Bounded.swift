typealias BoundedTupleRaytracingElement2<T0, T1> =
    TupleRaytracingElement2<T0, T1> where 
        T0: BoundedRaytracingElement, 
        T1: BoundedRaytracingElement

typealias BoundedTupleRaytracingElement3<T0, T1, T2> =
    TupleRaytracingElement3<T0, T1, T2> where 
        T0: BoundedRaytracingElement, 
        T1: BoundedRaytracingElement, 
        T2: BoundedRaytracingElement

typealias BoundedTupleRaytracingElement4<T0, T1, T2, T3> =
    TupleRaytracingElement4<T0, T1, T2, T3> where 
        T0: BoundedRaytracingElement, 
        T1: BoundedRaytracingElement, 
        T2: BoundedRaytracingElement, 
        T3: BoundedRaytracingElement

typealias BoundedTupleRaytracingElement5<T0, T1, T2, T3, T4> = 
    TupleRaytracingElement5<T0, T1, T2, T3, T4> where
        T0: BoundedRaytracingElement,
        T1: BoundedRaytracingElement,
        T2: BoundedRaytracingElement,
        T3: BoundedRaytracingElement, 
        T4: BoundedRaytracingElement

typealias BoundedTupleRaytracingElement6<T0, T1, T2, T3, T4, T5> =
    TupleRaytracingElement6<T0, T1, T2, T3, T4, T5> where
        T0: BoundedRaytracingElement,
        T1: BoundedRaytracingElement,
        T2: BoundedRaytracingElement,
        T3: BoundedRaytracingElement,
        T4: BoundedRaytracingElement, 
        T5: BoundedRaytracingElement

typealias BoundedTupleRaytracingElement7<T0, T1, T2, T3, T4, T5, T6> = 
    TupleRaytracingElement7<T0, T1, T2, T3, T4, T5, T6> where
        T0: BoundedRaytracingElement,
        T1: BoundedRaytracingElement,
        T2: BoundedRaytracingElement,
        T3: BoundedRaytracingElement,
        T4: BoundedRaytracingElement,
        T5: BoundedRaytracingElement, 
        T6: BoundedRaytracingElement

typealias BoundedTupleRaytracingElement8<T0, T1, T2, T3, T4, T5, T6, T7> = 
    TupleRaytracingElement8<T0, T1, T2, T3, T4, T5, T6, T7> where
        T0: BoundedRaytracingElement,
        T1: BoundedRaytracingElement,
        T2: BoundedRaytracingElement,
        T3: BoundedRaytracingElement,
        T4: BoundedRaytracingElement,
        T5: BoundedRaytracingElement,
        T6: BoundedRaytracingElement, 
        T7: BoundedRaytracingElement


extension BoundedTupleRaytracingElement2: BoundedRaytracingElement {
    func makeBounds() -> RaytracingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
    }
}

extension BoundedTupleRaytracingElement3: BoundedRaytracingElement {
    func makeBounds() -> RaytracingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
    }
}

extension BoundedTupleRaytracingElement4: BoundedRaytracingElement {
    func makeBounds() -> RaytracingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
    }
}

extension BoundedTupleRaytracingElement5: BoundedRaytracingElement {
    func makeBounds() -> RaytracingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
    }
}

extension BoundedTupleRaytracingElement6: BoundedRaytracingElement {
    func makeBounds() -> RaytracingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
        .union(t5.makeBounds())
    }
}

extension BoundedTupleRaytracingElement7: BoundedRaytracingElement {
    func makeBounds() -> RaytracingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
        .union(t5.makeBounds())
        .union(t6.makeBounds())
    }
}

extension BoundedTupleRaytracingElement8: BoundedRaytracingElement {
    func makeBounds() -> RaytracingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
        .union(t5.makeBounds())
        .union(t6.makeBounds())
        .union(t7.makeBounds())
    }
}
