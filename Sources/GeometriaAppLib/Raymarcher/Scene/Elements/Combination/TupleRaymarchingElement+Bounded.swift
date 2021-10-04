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
    func makeRaymarchingBounds() -> RaymarchingBounds {
        t0.makeRaymarchingBounds()
        .union(t1.makeRaymarchingBounds())
    }
}

extension BoundedTupleRaymarchingElement3: BoundedRaymarchingElement {
    func makeRaymarchingBounds() -> RaymarchingBounds {
        t0.makeRaymarchingBounds()
        .union(t1.makeRaymarchingBounds())
        .union(t2.makeRaymarchingBounds())
    }
}

extension BoundedTupleRaymarchingElement4: BoundedRaymarchingElement {
    func makeRaymarchingBounds() -> RaymarchingBounds {
        t0.makeRaymarchingBounds()
        .union(t1.makeRaymarchingBounds())
        .union(t2.makeRaymarchingBounds())
        .union(t3.makeRaymarchingBounds())
    }
}

extension BoundedTupleRaymarchingElement5: BoundedRaymarchingElement {
    func makeRaymarchingBounds() -> RaymarchingBounds {
        t0.makeRaymarchingBounds()
        .union(t1.makeRaymarchingBounds())
        .union(t2.makeRaymarchingBounds())
        .union(t3.makeRaymarchingBounds())
        .union(t4.makeRaymarchingBounds())
    }
}

extension BoundedTupleRaymarchingElement6: BoundedRaymarchingElement {
    func makeRaymarchingBounds() -> RaymarchingBounds {
        t0.makeRaymarchingBounds()
        .union(t1.makeRaymarchingBounds())
        .union(t2.makeRaymarchingBounds())
        .union(t3.makeRaymarchingBounds())
        .union(t4.makeRaymarchingBounds())
        .union(t5.makeRaymarchingBounds())
    }
}

extension BoundedTupleRaymarchingElement7: BoundedRaymarchingElement {
    func makeRaymarchingBounds() -> RaymarchingBounds {
        t0.makeRaymarchingBounds()
        .union(t1.makeRaymarchingBounds())
        .union(t2.makeRaymarchingBounds())
        .union(t3.makeRaymarchingBounds())
        .union(t4.makeRaymarchingBounds())
        .union(t5.makeRaymarchingBounds())
        .union(t6.makeRaymarchingBounds())
    }
}

extension BoundedTupleRaymarchingElement8: BoundedRaymarchingElement {
    func makeRaymarchingBounds() -> RaymarchingBounds {
        t0.makeRaymarchingBounds()
        .union(t1.makeRaymarchingBounds())
        .union(t2.makeRaymarchingBounds())
        .union(t3.makeRaymarchingBounds())
        .union(t4.makeRaymarchingBounds())
        .union(t5.makeRaymarchingBounds())
        .union(t6.makeRaymarchingBounds())
        .union(t7.makeRaymarchingBounds())
    }
}
