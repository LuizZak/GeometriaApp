struct AABBElement {
    var id: Int = 0
    var geometry: RAABB3D
    var material: Material
}

extension AABBElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        id == self.id ? self : nil
    }
}

extension AABBElement: BoundedElement {
    func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
