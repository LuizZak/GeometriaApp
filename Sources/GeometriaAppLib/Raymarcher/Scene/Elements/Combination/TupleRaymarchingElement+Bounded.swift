typealias BoundedTupleRaymarchingElement2<T0, T1> =
    TupleRaymarchingElement2<T0, T1> where 
        T0: BoundedRaymarchingElement, 
        T1: BoundedRaymarchingElement

typealias BoundedTupleRaymarchingElement3<T0, T1, T2> =
    TupleRaymarchingElement3<T0, T1, T2> where 
        T0: BoundedRaymarchingElement, 
        T1: BoundedRaymarchingElement, 
        T2: BoundedRaymarchingElement

typealias BoundedTupleRaymarchingElement4<T0, T1, T2, T3> =
    TupleRaymarchingElement4<T0, T1, T2, T3> where 
        T0: BoundedRaymarchingElement, 
        T1: BoundedRaymarchingElement, 
        T2: BoundedRaymarchingElement, 
        T3: BoundedRaymarchingElement

typealias BoundedTupleRaymarchingElement5<T0, T1, T2, T3, T4> = 
    TupleRaymarchingElement5<T0, T1, T2, T3, T4> where
        T0: BoundedRaymarchingElement,
        T1: BoundedRaymarchingElement,
        T2: BoundedRaymarchingElement,
        T3: BoundedRaymarchingElement, 
        T4: BoundedRaymarchingElement

typealias BoundedTupleRaymarchingElement6<T0, T1, T2, T3, T4, T5> =
    TupleRaymarchingElement6<T0, T1, T2, T3, T4, T5> where
        T0: BoundedRaymarchingElement,
        T1: BoundedRaymarchingElement,
        T2: BoundedRaymarchingElement,
        T3: BoundedRaymarchingElement,
        T4: BoundedRaymarchingElement, 
        T5: BoundedRaymarchingElement

typealias BoundedTupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6> = 
    TupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6> where
        T0: BoundedRaymarchingElement,
        T1: BoundedRaymarchingElement,
        T2: BoundedRaymarchingElement,
        T3: BoundedRaymarchingElement,
        T4: BoundedRaymarchingElement,
        T5: BoundedRaymarchingElement, 
        T6: BoundedRaymarchingElement

typealias BoundedTupleRaymarchingElement8<T0, T1, T2, T3, T4, T5, T6, T7> = 
    TupleRaymarchingElement8<T0, T1, T2, T3, T4, T5, T6, T7> where
        T0: BoundedRaymarchingElement,
        T1: BoundedRaymarchingElement,
        T2: BoundedRaymarchingElement,
        T3: BoundedRaymarchingElement,
        T4: BoundedRaymarchingElement,
        T5: BoundedRaymarchingElement,
        T6: BoundedRaymarchingElement, 
        T7: BoundedRaymarchingElement


extension BoundedTupleRaymarchingElement2: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
    }
}

extension BoundedTupleRaymarchingElement3: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
    }
}

extension BoundedTupleRaymarchingElement4: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
    }
}

extension BoundedTupleRaymarchingElement5: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
    }
}

extension BoundedTupleRaymarchingElement6: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
        .union(t5.makeBounds())
    }
}

extension BoundedTupleRaymarchingElement7: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
        .union(t5.makeBounds())
        .union(t6.makeBounds())
    }
}

extension BoundedTupleRaymarchingElement8: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
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
