typealias BoundedTupleElement2<T0: BoundedElement, T1: BoundedElement> =
    TupleElement2<T0, T1>

typealias BoundedTupleElement3<T0: BoundedElement, T1: BoundedElement, T2: BoundedElement> =
    TupleElement3<T0, T1, T2>

typealias BoundedTupleElement4<T0: BoundedElement, T1: BoundedElement, T2: BoundedElement, T3: BoundedElement> =
    TupleElement4<T0, T1, T2, T3>

typealias BoundedTupleElement5<T0: BoundedElement, T1: BoundedElement, T2: BoundedElement, T3: BoundedElement, T4: BoundedElement> =
    TupleElement5<T0, T1, T2, T3, T4>

typealias BoundedTupleElement6<T0: BoundedElement, T1: BoundedElement, T2: BoundedElement, T3: BoundedElement, T4: BoundedElement, T5: BoundedElement> =
    TupleElement6<T0, T1, T2, T3, T4, T5>

typealias BoundedTupleElement7<T0: BoundedElement, T1: BoundedElement, T2: BoundedElement, T3: BoundedElement, T4: BoundedElement, T5: BoundedElement, T6: BoundedElement> =
    TupleElement7<T0, T1, T2, T3, T4, T5, T6>

typealias BoundedTupleElement8<T0: BoundedElement, T1: BoundedElement, T2: BoundedElement, T3: BoundedElement, T4: BoundedElement, T5: BoundedElement, T6: BoundedElement, T7: BoundedElement> =
    TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>

extension BoundedTupleElement2: BoundedElement {
    @inlinable
    func makeBounds() -> ElementBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
    }
}

extension BoundedTupleElement3: BoundedElement {
    @inlinable
    func makeBounds() -> ElementBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
    }
}

extension BoundedTupleElement4: BoundedElement {
    @inlinable
    func makeBounds() -> ElementBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
    }
}

extension BoundedTupleElement5: BoundedElement {
    @inlinable
    func makeBounds() -> ElementBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
    }
}

extension BoundedTupleElement6: BoundedElement {
    @inlinable
    func makeBounds() -> ElementBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
        .union(t5.makeBounds())
    }
}

extension BoundedTupleElement7: BoundedElement {
    @inlinable
    func makeBounds() -> ElementBounds {
        t0.makeBounds()
        .union(t1.makeBounds())
        .union(t2.makeBounds())
        .union(t3.makeBounds())
        .union(t4.makeBounds())
        .union(t5.makeBounds())
        .union(t6.makeBounds())
    }
}

extension BoundedTupleElement8: BoundedElement {
    @inlinable
    func makeBounds() -> ElementBounds {
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
