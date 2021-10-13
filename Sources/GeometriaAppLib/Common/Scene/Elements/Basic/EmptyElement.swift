struct EmptyElement {

}

extension EmptyElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
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
