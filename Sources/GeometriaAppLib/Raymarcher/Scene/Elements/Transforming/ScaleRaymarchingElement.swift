typealias ScaleRaymarchingElement<T: RaymarchingElement> = ScaleElement<T>

extension ScaleRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var result = element.signedDistance(
            to: (point - scalingCenter) / scaling + scalingCenter, 
            current: .emptyResult()
        )

        // We need to de-scale the resulting distance back to world coordinates 
        // before returning
        result.distance *= scaling
        
        return min(result, current)
    }
}