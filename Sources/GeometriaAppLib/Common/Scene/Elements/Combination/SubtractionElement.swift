struct SubtractionElement<T0: Element, T1: Element> {
    var id: Int = 0
    var material: Int? = nil
    var t0: T0
    var t1: T1
}

extension SubtractionElement: Element {
    @inlinable
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
        
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    @inlinable
    func queryScene(id: Int) -> Element? {
        if id == self.id { return self }
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension SubtractionElement: BoundedElement where T0: BoundedElement {
    // TODO: Bounds are guaranteed to be no bigger than t0's area but maybe there 
    // TODO: are better ways to generate a bounding box here.
    @inlinable
    func makeBounds() -> ElementBounds {
        t0.makeBounds()
    }
}

@_transparent
func subtraction<T0, T1>(@ElementBuilder _ builder: () -> TupleElement2<T0, T1>) -> SubtractionElement<T0, T1> {
    let value = builder()

    return .init(t0: value.t0, t1: value.t1)
}

@_transparent
func subtraction<T0, T1, T2>(@ElementBuilder _ builder: () -> TupleElement3<T0, T1, T2>) -> SubtractionElement<SubtractionElement<T0, T1>, T2> {
    let value = builder()

    return .init(t0: .init(t0: value.t0, t1: value.t1), t1: value.t2)
}

@_transparent
func subtraction<T0, T1, T2, T3>(@ElementBuilder _ builder: () -> TupleElement4<T0, T1, T2, T3>) -> SubtractionElement<SubtractionElement<SubtractionElement<T0, T1>, T2>, T3> {
    let value = builder()

    return .init(t0: .init(t0: .init(t0: value.t0, t1: value.t1), t1: value.t2), t1: value.t3)
}
