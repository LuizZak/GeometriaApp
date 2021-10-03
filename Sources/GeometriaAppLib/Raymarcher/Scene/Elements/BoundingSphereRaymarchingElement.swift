struct BoundingSphereRaymarchingElement<T>: BoundedRaymarchingElement where T: RaymarchingElement {
    var element: T
    var boundingSphere: RSphere3D
    var bounds: RaymarchingBounds
    
    init(element: T, boundingSphere: RSphere3D) {
        self.element = element
        self.boundingSphere = boundingSphere
        bounds = RaymarchingBounds.makeBounds(for: boundingSphere)
    }
    
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingSphere.signedDistance(to: point) < current.distance else {
            return current
        }
        
        return element.signedDistance(to: point, current: current)
    }

    func makeBounds() -> RaymarchingBounds {
        bounds
    }
}

extension BoundingSphereRaymarchingElement {
    init<Geometry>(geometry: Geometry, material: RaymarcherMaterial) where Geometry: SignedDistanceMeasurableType & BoundableType, Geometry.Vector == RVector3D, T == GeometryRaymarchingElement<Geometry> {
        let bounds = geometry.bounds
        let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
        
        let element = GeometryRaymarchingElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingSphere: sphere)
    }
}
