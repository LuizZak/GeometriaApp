typealias IntersectionRaymarchingElement<T0: RaymarchingElement, T1: RaymarchingElement> = 
    IntersectionElement<T0, T1>

// Reference for distance function modifiers:
// https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
extension IntersectionRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let v0 = t0.signedDistance(to: point, current: current)
        let v1 = t1.signedDistance(to: point, current: current)
        
        let result = max(v0, v1)
        if result < current {
            return result.withMaterial(material ?? result.material)
        }
        
        return current
    }
}
