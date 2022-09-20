struct AnyBoundedElement {
    var element: BoundedElement

    init<T: BoundedElement>(_ element: T) {
        self.element = element
    }
}

extension AnyBoundedElement: Element {
    var id: Int {
        get {
            element.id
        }
        set {
            element.id = newValue
        }
    }

    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Element.Id) -> Element? {
        element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}

extension AnyBoundedElement: BoundedElement {
    func makeBounds() -> ElementBounds {
        return element.makeBounds()
    }
}
