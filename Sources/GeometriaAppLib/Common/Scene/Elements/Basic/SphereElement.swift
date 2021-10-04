struct SphereElement {
    var id: Int = 0
    var geometry: RSphere3D
    var material: Material
}

extension SphereElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        id == self.id ? self : nil
    }
}

extension SphereElement: BoundedElement {
    func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
