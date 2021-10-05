struct SubtractionElement<T0: Element, T1: Element> {
    var t0: T0
    var t1: T1
}

extension SubtractionElement: Element {
    @inlinable
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    @inlinable
    func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }
}

extension SubtractionElement: BoundedElement where T0: BoundedElement {
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
