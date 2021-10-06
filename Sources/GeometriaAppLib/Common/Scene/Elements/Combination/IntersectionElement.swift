struct IntersectionElement<T0: Element, T1: Element> {
    var id: Int = 0
    var material: Int? = nil // TODO: Add support for this property in Raymarcher too
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
    func queryScene(id: Int) -> Element? {
        if id == self.id { return self }
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }
}

extension IntersectionElement: BoundedElement where T0: BoundedElement, T1: BoundedElement {
    // TODO: Bounds are guaranteed to be no bigger than the intersection area
    // TODO: between t0 and t1, but maybe there are better ways to generate a 
    // TODO: bounding box here.
    func makeBounds() -> ElementBounds {
        let t0Bounds = t0.makeBounds()

        return t0Bounds.intersection(t1.makeBounds()) ?? t0Bounds
    }
}

@_transparent
func intersection<T0, T1>(@ElementBuilder _ builder: () -> TupleElement2<T0, T1>) -> IntersectionElement<T0, T1> {
    let value = builder()

    return .init(t0: value.t0, t1: value.t1)
}
