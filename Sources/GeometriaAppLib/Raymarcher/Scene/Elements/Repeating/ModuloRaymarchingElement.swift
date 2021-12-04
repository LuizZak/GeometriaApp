struct ModuloRaymarchingElement<T: RaymarchingElement>: RaymarchingElement {
    var id: Int = 0
    var element: T
    var phase: RVector3D

    @_transparent
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: abs(point) % phase, current: current)
    }
}

extension ModuloRaymarchingElement: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
