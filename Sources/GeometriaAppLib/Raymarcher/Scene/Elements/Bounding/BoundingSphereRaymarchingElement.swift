#if canImport(Geometria)
import Geometria
#endif

public typealias BoundingSphereRaymarchingElement<T: RaymarchingElement> = 
    BoundingSphereElement<T>

extension BoundingSphereRaymarchingElement: RaymarchingElement & RaymarchingBoundedElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingSphere.signedDistance(to: point) < current.distance else {
            return current
        }
        
        return element.signedDistance(to: point, current: current)
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
