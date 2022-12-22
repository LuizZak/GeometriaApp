public struct TypedArrayElement<T: Element> {
    public var id: Element.Id = 0
    public var elements: [T]

    public init(id: Element.Id = 0, elements: [T]) {
        self.id = id
        self.elements = elements
    }
}

extension TypedArrayElement: Element {
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        elements = elements.map {
            var el = $0
            el.attributeIds(&idFactory)
            return el
        }
    }

    @inlinable
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        
        for element in elements {
            if let result = element.queryScene(id: id) {
                return result
            }
        }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
