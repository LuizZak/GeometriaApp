public struct SubtractionElement<T0: Element, T1: Element> {
    public var id: Element.Id = 0
    public var material: Int? = nil
    public var t0: T0
    public var t1: T1

    public init(id: Element.Id = 0, material: Int? = nil, t0: T0, t1: T1) {
        self.id = id
        self.material = material
        self.t0 = t0
        self.t1 = t1
    }
}

extension SubtractionElement: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
        
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension SubtractionElement: BoundedElement where T0: BoundedElement {
    // TODO: Bounds are guaranteed to be no bigger than t0's area but maybe there 
    // TODO: are better ways to generate a bounding box here.
    @inlinable
    public func makeBounds() -> ElementBounds {
        t0.makeBounds()
    }
}

@_transparent
public func subtraction<T0, T1>(@ElementBuilder _ builder: () -> TupleElement2<T0, T1>) -> SubtractionElement<T0, T1> {
    let value = builder()

    return SubtractionElement(
        t0: value.t0,
        t1: value.t1
    )
}

@_transparent
public func subtraction<T0, T1, T2>(@ElementBuilder _ builder: () -> TupleElement3<T0, T1, T2>) -> SubtractionElement<SubtractionElement<T0, T1>, T2> {
    let value = builder()

    return SubtractionElement(
        t0: SubtractionElement(
            t0: value.t0,
            t1: value.t1
        ),
        t1: value.t2
    )
}

@_transparent
public func subtraction<T0, T1, T2, T3>(@ElementBuilder _ builder: () -> TupleElement4<T0, T1, T2, T3>) -> SubtractionElement<SubtractionElement<SubtractionElement<T0, T1>, T2>, T3> {
    let value = builder()

    return SubtractionElement(
        t0: SubtractionElement(
            t0: SubtractionElement(
                t0: value.t0,
                t1: value.t1
            ),
            t1: value.t2
        ),
        t1: value.t3
    )
}
