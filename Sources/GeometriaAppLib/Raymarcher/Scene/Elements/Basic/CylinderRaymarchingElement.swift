struct CylinderRaymarchingElement: RaymarchingElement {
    var geometry: RCylinder3D
    var boundingSphere: RSphere3D

    init(geometry: RCylinder3D) {
        self.geometry = geometry
        boundingSphere = RSphere3D(center: geometry.bounds.center, radius: geometry.bounds.size.maximalComponent / 2)
    }

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingSphere.signedDistance(to: point) < current.distance else {
            return current
        }
        
        let distance = geometry.signedDistance(to: point)
        
        if distance < current.distance {
            return .init(distance: distance)
        }

        return current
    }
}
