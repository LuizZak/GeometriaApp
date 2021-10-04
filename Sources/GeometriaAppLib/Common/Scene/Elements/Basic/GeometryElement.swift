struct GeometryElement<T> {
    var id: Int = 0
    var geometry: T
    var material: Material
}

extension GeometryElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        id == self.id ? self : nil
    }
}

extension GeometryElement: BoundedElement where T: BoundableType, T.Vector == RVector3D {
    func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
