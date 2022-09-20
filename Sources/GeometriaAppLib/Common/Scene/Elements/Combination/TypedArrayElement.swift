struct TypedArrayElement<T: Element> {
    var id: Element.Id = 0
    var elements: [T]
}

extension TypedArrayElement: Element {
    @inlinable
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        elements = elements.map {
            var el = $0
            el.attributeIds(&idFactory)
            return el
        }
    }

    @inlinable
    func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        
        for element in elements {
            if let result = element.queryScene(id: id) {
                return result
            }
        }

        return nil
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
