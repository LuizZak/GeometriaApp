struct ArrayRaymarchingElement {
    var elements: [RaymarchingElement]
}

extension ArrayRaymarchingElement: Element {
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

extension ArrayRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        for el in elements {
            current = el.signedDistance(to: point, current: current)
        }
        
        return current
    }
}
