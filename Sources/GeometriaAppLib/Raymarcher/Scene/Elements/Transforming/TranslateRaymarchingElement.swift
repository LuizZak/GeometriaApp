public typealias TranslateRaymarchingElement<T: RaymarchingElement> = TranslateElement<T>

extension TranslateRaymarchingElement: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: point - translation, current: current)
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
