struct OperationRaymarchingElement<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    var id: Int = 0
    var t0: T0
    var t1: T1
    var operation: (RaymarchingResult, RaymarchingResult) -> RaymarchingResult

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let t0Result = t0.signedDistance(to: point, current: current)
        let t1Result = t1.signedDistance(to: point, current: current)

        return min(current, operation(t0Result, t1Result))
    }
}

extension OperationRaymarchingElement: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
