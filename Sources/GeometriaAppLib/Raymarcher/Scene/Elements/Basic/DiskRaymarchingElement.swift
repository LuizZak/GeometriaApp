struct DiskRaymarchingElement: BoundedRaymarchingElement {
    var geometry: RDisk3D
    var material: RaymarcherMaterial

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let distance = geometry.signedDistance(to: point)
        
        guard distance < current.distance else {
            return current
        }

        return .init(distance: distance, material: material)
    }

    func makeBounds() -> RaymarchingBounds {
        RaymarchingBounds.makeBounds(for: geometry)
    }
}
