#if canImport(Geometria)
import Geometria
#endif

typealias RotateRaymarchingElement<T: RaymarchingElement> = RotateElement<T>

extension RotateRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(
            to: point.rotatedBy(rotation.mInv, around: rotationCenter),
            current: current
        )
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
