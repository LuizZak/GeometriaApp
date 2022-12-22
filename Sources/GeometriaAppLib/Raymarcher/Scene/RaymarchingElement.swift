public protocol RaymarchingElement: Element {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType
}
