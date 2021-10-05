struct EllipseElement {
    var id: Int = 0
    var geometry: REllipse3D
    var material: MaterialId
}

extension EllipseElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        id == self.id ? self : nil
    }
}

extension EllipseElement: BoundedElement {
    func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
