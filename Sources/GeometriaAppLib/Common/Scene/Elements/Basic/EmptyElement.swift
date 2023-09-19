#if canImport(Geometria)
import Geometria
#endif

public struct EmptyElement {
    public var id: Element.Id = 0

    public init(id: Element.Id = 0) {
        self.id = id
    }
}

extension EmptyElement: Element {
    @_transparent
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()
    }

    @_transparent
    public func queryScene(id: Element.Id) -> Element? {
        nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension EmptyElement: BoundedElement {
    @_transparent
    public func makeBounds() -> ElementBounds {
        .zero
    }
}
