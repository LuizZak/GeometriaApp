struct BoundedArrayRaymarchingElement {
    var id: Int = 0
    var elements: [RaymarchingElement & BoundedElement]
}

extension BoundedArrayRaymarchingElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

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

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension BoundedArrayRaymarchingElement: BoundedElement {
    func makeBounds() -> RaymarchingBounds {
        elements.map { $0.makeBounds() }.reduce(.zero) { $0.union($1) }
    }
}

extension BoundedArrayRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        for el in elements {
            current = el.signedDistance(to: point, current: current)
        }
        
        return current
    }
}
