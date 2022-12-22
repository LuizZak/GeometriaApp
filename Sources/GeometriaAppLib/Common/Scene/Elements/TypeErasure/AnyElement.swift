public struct AnyElement {
    public var element: Element

    public init<T: Element>(_ element: T) {
        self.element = element
    }
}

extension AnyElement: Element {
    public var id: Int {
        get {
            element.id
        }
        set {
            element.id = newValue
        }
    }

    @_transparent
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    @_transparent
    public func queryScene(id: Element.Id) -> Element? {
        element.queryScene(id: id)
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        element.accept(visitor)
    }
}
