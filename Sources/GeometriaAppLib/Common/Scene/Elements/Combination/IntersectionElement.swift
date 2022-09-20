struct IntersectionElement<T0: Element, T1: Element> {
    var id: Element.Id = 0
    var material: Int? = nil
    var t0: T0
    var t1: T1
}

extension IntersectionElement: Element {
    @inlinable
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
        
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    @inlinable
    func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension IntersectionElement: BoundedElement where T0: BoundedElement, T1: BoundedElement {
    func makeBounds() -> ElementBounds {
        let t0Bounds = t0.makeBounds()

        return t0Bounds.intersection(t1.makeBounds()) ?? t0Bounds
    }
}

// Convenience when disabling elements in intersection to inspect a single geometry
// at a time
@_transparent
func intersection<T0>(@ElementBuilder _ builder: () -> T0) -> T0 {
    let value = builder()

    return value
}

@_transparent
func intersection<T0, T1>(@ElementBuilder _ builder: () -> TupleElement2<T0, T1>) -> IntersectionElement<T0, T1> {
    let value = builder()

    return IntersectionElement(
        t0: value.t0,
        t1: value.t1
    )
}

@_transparent
func intersection<T0, T1, T2>(@ElementBuilder _ builder: () -> TupleElement3<T0, T1, T2>) -> IntersectionElement<IntersectionElement<T0, T1>, T2> {
    let value = builder()

    return IntersectionElement(
        t0: IntersectionElement(
            t0: value.t0,
            t1: value.t1
        ),
        t1: value.t2
    )
}

@_transparent
func intersection<T0, T1, T2, T3>(@ElementBuilder _ builder: () -> TupleElement4<T0, T1, T2, T3>) -> IntersectionElement<IntersectionElement<IntersectionElement<T0, T1>, T2>, T3> {
    let value = builder()

    return IntersectionElement(
        t0: IntersectionElement(
            t0: IntersectionElement(
                t0: value.t0,
                t1: value.t1
            ),
            t1: value.t2
        ),
        t1: value.t3
    )
}

@_transparent
func intersection<T0, T1, T2, T3, T4>(@ElementBuilder _ builder: () -> TupleElement5<T0, T1, T2, T3, T4>) -> IntersectionElement<IntersectionElement<IntersectionElement<IntersectionElement<T0, T1>, T2>, T3>, T4> {
    let value = builder()

    return IntersectionElement(
        t0: IntersectionElement(
            t0: IntersectionElement(
                t0: IntersectionElement(
                    t0: value.t0,
                    t1: value.t1
                ),
                t1: value.t2
            ),
            t1: value.t3
        ),
        t1: value.t4
    )
}

@_transparent
func intersection<T0, T1, T2, T3, T4, T5>(@ElementBuilder _ builder: () -> TupleElement6<T0, T1, T2, T3, T4, T5>) -> IntersectionElement<IntersectionElement<IntersectionElement<IntersectionElement<IntersectionElement<T0, T1>, T2>, T3>, T4>, T5> {
    let value = builder()

    return IntersectionElement(
        t0: IntersectionElement(
            t0: IntersectionElement(
                t0: IntersectionElement(
                    t0: IntersectionElement(
                        t0: value.t0,
                        t1: value.t1
                    ),
                    t1: value.t2
                ),
                t1: value.t3
            ),
            t1: value.t4
        ),
        t1: value.t5
    )
}
