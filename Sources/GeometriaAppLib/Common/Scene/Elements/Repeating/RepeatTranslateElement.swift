#if canImport(Geometria)
import Geometria
#endif

public struct RepeatTranslateElement<T: Element> {
    public var id: Element.Id = 0
    public var element: T
    public var translation: RVector3D
    public var count: Int

    public init(id: Element.Id = 0, element: T, translation: RVector3D, count: Int) {
        self.id = id
        self.element = element
        self.translation = translation
        self.count = count
    }
}

extension RepeatTranslateElement: Element {
    @_transparent
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    @_transparent
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        
        return element.queryScene(id: id)
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension RepeatTranslateElement: BoundedElement where T: BoundedElement {
    @inlinable
    public func makeBounds() -> ElementBounds {
        let bounds = element.makeBounds()
        
        return bounds.union(bounds.offsetBy(translation * Double(count - 1)))
    }
}

extension Element {
    @_transparent
    public func repeatTranslated(count: Int, translation: RVector3D) -> RepeatTranslateElement<Self> {
        .init(element: self, translation: translation, count: count)
    }
}

@_transparent
public func repeatTranslated<T: Element>(count: Int, translation: RVector3D, @ElementBuilder _ builder: () -> T) -> RepeatTranslateElement<T> {
    builder().repeatTranslated(count: count, translation: translation)
}
