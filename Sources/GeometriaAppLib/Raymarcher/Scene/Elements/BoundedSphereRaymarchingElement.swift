struct BoundedSphereRaymarchingElement<T>: RaymarchingElement where T: RaymarchingElement {
    var element: T
    var boundingSphere: RSphere3D
    
    init(element: T, boundingSphere: RSphere3D) {
        self.element = element
        self.boundingSphere = boundingSphere
    }
    
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingSphere.signedDistance(to: point) < current.distance else {
            return current
        }
        
        return element.signedDistance(to: point, current: current)
    }
}

extension BoundedSphereRaymarchingElement {
    init<Geometry>(geometry: Geometry, material: RaymarcherMaterial) where Geometry: SignedDistanceMeasurableType & BoundableType, Geometry.Vector == RVector3D, T == GeometryRaymarchingElement<Geometry> {
        let bounds = geometry.bounds
        let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
        
        let element = GeometryRaymarchingElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingSphere: sphere)
    }
}
