#if canImport(Geometria)
import Geometria
#endif

public typealias RotateRaymarchingElement<T: RaymarchingElement> = RotateElement<T>

extension RotateRaymarchingElement: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(
            to: point.rotatedBy(rotation.mInv, around: rotationCenter),
            current: current
        )
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
