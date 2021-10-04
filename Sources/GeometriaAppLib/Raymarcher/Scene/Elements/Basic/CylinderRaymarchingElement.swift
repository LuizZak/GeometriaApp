struct CylinderRaymarchingElement {
    var geometry: RCylinder3D
    var material: RaymarcherMaterial
}

extension CylinderRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let distance = geometry.signedDistance(to: point)
        
        guard distance < current.distance else {
            return current
        }

        return .init(distance: distance, material: material)
    }
}

extension CylinderRaymarchingElement: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
        RaymarchingBounds.makeBounds(for: geometry)
    }
}
