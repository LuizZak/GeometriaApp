struct AnyElement {
    var element: Element

    init<T: Element>(_ element: T) {
        self.element = element
    }
}

extension AnyElement: Element {
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
    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}
