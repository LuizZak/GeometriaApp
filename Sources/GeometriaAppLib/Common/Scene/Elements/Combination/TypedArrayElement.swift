struct TypedArrayElement<T: Element> {
    var elements: [T]
}

extension TypedArrayElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        elements = elements.map {
            var el = $0
            el.attributeIds(&idFactory)
            return el
        }
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        for element in elements {
            if let result = element.queryScene(id: id) {
                return result
            }
        }

        return nil
    }
}
