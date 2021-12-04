struct RepeatTranslateElement<T: Element> {
    var id: Int = 0
    var element: T
    var translation: RVector3D
    var count: Int
}

extension RepeatTranslateElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension RepeatTranslateElement: BoundedElement where T: BoundedElement {
    @inlinable
    func makeBounds() -> RaymarchingBounds {
        let bounds = element.makeBounds()
        
        return bounds.union(bounds.offsetBy(translation * Double(count - 1)))
    }
}

extension Element {
    @_transparent
    func repeatTranslated(count: Int, translation: RVector3D) -> RepeatTranslateElement<Self> {
        .init(element: self, translation: translation, count: count)
    }
}

@_transparent
func repeatTranslated<T: Element>(count: Int, translation: RVector3D, @ElementBuilder _ builder: () -> T) -> RepeatTranslateElement<T> {
    builder().repeatTranslated(count: count, translation: translation)
}
