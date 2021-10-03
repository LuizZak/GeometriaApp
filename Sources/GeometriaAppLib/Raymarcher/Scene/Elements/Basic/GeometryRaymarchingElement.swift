struct GeometryRaymarchingElement<T: SignedDistanceMeasurableType>: RaymarchingElement where T.Vector == RVector3D {
    var geometry: T
    var material: RaymarcherMaterial

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let distance = geometry.signedDistance(to: point)
        
        guard distance < current.distance else {
            return current
        }
        
        return .init(distance: distance, material: material)
    }
}

extension GeometryRaymarchingElement: BoundedRaymarchingElement where T: BoundableType {
    func makeBounds() -> RaymarchingBounds {
        RaymarchingBounds.makeBounds(for: geometry)
    }
}
