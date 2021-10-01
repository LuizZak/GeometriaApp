struct GeometryRaymarchingElement<T: SignedDistanceMeasurableType>: RaymarchingElement where T.Vector == RVector3D {
    var geometry: T

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let distance = geometry.signedDistance(to: point)
        
        if distance < current.distance {
            return .init(distance: distance)
        }

        return current
    }
}
