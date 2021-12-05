struct AnyBoundedElement {
    private var _element: BoundedElement

    init<T: BoundedElement>(_ element: T) {
        _element = element
    }
}

extension AnyBoundedElement: Element {
    var id: Int {
        get {
            _element.id
        }
        set {
            _element.id = newValue
        }
    }

    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        _element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        _element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        _element.accept(visitor)
    }
}

extension AnyBoundedElement: BoundedElement {
    func makeBounds() -> ElementBounds {
        return _element.makeBounds()
    }
}
