struct CylinderElement {
    var id: Int = 0
    var geometry: RCylinder3D
    var material: Material
}

extension CylinderElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        id == self.id ? self : nil
    }
}

extension CylinderElement: BoundedElement {
    func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
