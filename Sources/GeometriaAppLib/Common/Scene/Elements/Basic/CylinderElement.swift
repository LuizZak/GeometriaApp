#if canImport(Geometria)
import Geometria
#endif

public struct CylinderElement: GeometryElementType {
    public var id: Element.Id = 0
    public var geometry: RCylinder3D
    public var material: MaterialId

    public init(id: Element.Id = 0, geometry: RCylinder3D, material: MaterialId) {
        self.id = id
        self.geometry = geometry
        self.material = material
    }
}

extension CylinderElement: Element {
    @_transparent
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    public func queryScene(id: Element.Id) -> Element? {
        id == self.id ? self : nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension CylinderElement: BoundedElement {
    @_transparent
    public func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
