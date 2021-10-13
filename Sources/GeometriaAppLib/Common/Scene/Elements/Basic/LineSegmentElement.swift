struct LineSegmentElement {
    var id: Int = 0
    var geometry: RLineSegment3D
    var material: MaterialId
}

extension LineSegmentElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        id == self.id ? self : nil
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension LineSegmentElement: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
