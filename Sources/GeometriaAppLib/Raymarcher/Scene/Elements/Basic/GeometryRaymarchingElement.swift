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
}

extension GeometryRaymarchingElement: BoundedRaymarchingElement where T: SignedDistanceMeasurableType & BoundableType, T.Vector == RVector3D {
    func makeRaymarchingBounds() -> RaymarchingBounds {
        RaymarchingBounds.makeRaymarchingBounds(for: geometry)
    }
}
