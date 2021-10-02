struct CylinderRaymarchingElement: RaymarchingElement {
    var geometry: RCylinder3D
    var material: RaymarcherMaterial
    var boundingSphere: RSphere3D

    init(geometry: RCylinder3D, material: RaymarcherMaterial) {
        self.geometry = geometry
        self.material = material
        boundingSphere = RSphere3D(center: geometry.bounds.center, radius: geometry.bounds.size.maximalComponent / 2)
    }

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingSphere.signedDistance(to: point) < current.distance else {
            return current
        }
        
        let distance = geometry.signedDistance(to: point)
        
        guard distance < current.distance else {
            return current
        }

        return .init(distance: distance, material: material)
    }
}
