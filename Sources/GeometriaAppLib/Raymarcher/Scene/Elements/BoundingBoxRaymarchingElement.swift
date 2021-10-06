typealias BoundingBoxRaymarchingElement<T: RaymarchingElement> = 
    BoundingBoxElement<T>

extension BoundingBoxRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingBox.clamp(point).distanceSquared(to: point) < current.distance * current.distance else {
            return current
        }
        
        return element.signedDistance(to: point, current: current)
    }
}
