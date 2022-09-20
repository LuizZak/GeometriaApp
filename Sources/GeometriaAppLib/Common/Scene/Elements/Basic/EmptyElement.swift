struct EmptyElement {
    var id: Element.Id = 0
}

extension EmptyElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Element.Id) -> Element? {
        nil
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension EmptyElement: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        .zero
    }
}
