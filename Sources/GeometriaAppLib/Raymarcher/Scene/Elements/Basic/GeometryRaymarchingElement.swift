#if canImport(Geometria)
import Geometria
#endif

typealias GeometryRaymarchingElement<T> = GeometryElement<T>

extension GeometryRaymarchingElement: RaymarchingElement where T: SignedDistanceMeasurableType, T.Vector == RVector3D {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let distance = geometry.signedDistance(to: point)
        
        guard distance < current.distance else {
            return current
        }

        return .init(distance: distance, material: material)
    }

    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
