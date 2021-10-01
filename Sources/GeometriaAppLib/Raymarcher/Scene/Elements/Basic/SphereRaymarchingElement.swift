struct SphereRaymarchingElement: RaymarchingElement {
    var geometry: RSphere3D

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let distance = geometry.signedDistance(to: point)
        
        if distance < current.distance {
            return .init(distance: distance)
        }

        return current
    }
}
