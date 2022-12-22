public struct OperationRaymarchingElement<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    public var id: Int = 0
    public var t0: T0
    public var t1: T1
    public var operation: (RaymarchingResult, RaymarchingResult) -> RaymarchingResult

    public init(
        id: Int = 0,
        t0: T0,
        t1: T1,
        operation: @escaping (RaymarchingResult, RaymarchingResult) -> RaymarchingResult
    ) {

        self.id = id
        self.t0 = t0
        self.t1 = t1
        self.operation = operation
    }

    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let t0Result = t0.signedDistance(to: point, current: current)
        let t1Result = t1.signedDistance(to: point, current: current)

        return min(current, operation(t0Result, t1Result))
    }
}

extension OperationRaymarchingElement: Element {
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    public func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
