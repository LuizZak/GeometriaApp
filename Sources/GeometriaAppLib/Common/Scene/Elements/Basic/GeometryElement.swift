#if canImport(Geometria)
import Geometria
#endif

struct GeometryElement<T>: GeometryElementType {
    var id: Element.Id = 0
    var geometry: T
    var material: MaterialId
}

extension GeometryElement: Element {
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

extension GeometryElement: BoundedElement where T: BoundableType, T.Vector == RVector3D {
    @_transparent
    func makeBounds() -> ElementBounds {
        .makeBounds(for: geometry)
    }
}
