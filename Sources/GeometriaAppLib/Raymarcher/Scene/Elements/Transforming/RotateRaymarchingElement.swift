typealias RotateRaymarchingElement<T: RaymarchingElement> = RotateElement<T>

extension RotateRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        return element.signedDistance(
            to: point.rotated(by: rotationInv, around: rotationCenter),
            current: .emptyResult()
        )
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
