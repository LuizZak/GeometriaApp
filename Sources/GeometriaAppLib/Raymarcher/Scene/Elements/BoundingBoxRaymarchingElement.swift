typealias BoundingBoxRaymarchingElement<T: RaymarchingElement> = 
    BoundingBoxElement<T>

extension BoundingBoxRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let clamped = boundingBox.clamp(point)
        guard clamped == point || clamped.distanceSquared(to: point) < current.distance * current.distance else {
            return current
        }
        
        return element.signedDistance(to: point, current: current)
    }
}
