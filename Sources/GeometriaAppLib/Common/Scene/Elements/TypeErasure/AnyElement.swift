struct AnyElement {
    private var _element: Element

    init<T: Element>(_ element: T) {
        _element = element
    }
}

extension AnyElement: Element {
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
