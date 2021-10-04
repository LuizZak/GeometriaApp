typealias BoundingSphereRaymarchingElement<T: RaymarchingElement> = 
    BoundingSphereElement<T>

extension BoundingSphereRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingSphere.signedDistance(to: point) < current.distance else {
            return current
        }
        
        return element.signedDistance(to: point, current: current)
    }
}
