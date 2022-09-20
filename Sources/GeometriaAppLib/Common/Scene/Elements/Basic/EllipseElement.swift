struct EllipseElement: GeometryElementType {
    var id: Element.Id = 0
    var geometry: REllipse3D
    var material: MaterialId
}

extension EllipseElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Element.Id) -> Element? {
        id == self.id ? self : nil
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension EllipseElement: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
