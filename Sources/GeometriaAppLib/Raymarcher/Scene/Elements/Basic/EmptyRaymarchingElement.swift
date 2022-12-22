public typealias EmptyRaymarchingElement = EmptyElement

extension EmptyRaymarchingElement: RaymarchingElement {
    @_transparent
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
