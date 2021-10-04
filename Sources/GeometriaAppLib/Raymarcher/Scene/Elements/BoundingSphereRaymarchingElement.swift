struct BoundingSphereRaymarchingElement<T>: BoundedRaymarchingElement where T: RaymarchingElement {
    var element: T
    var boundingSphere: RSphere3D
    var bounds: RaymarchingBounds
    
    init(element: T, boundingSphere: RSphere3D) {
        self.element = element
        self.boundingSphere = boundingSphere
        bounds = RaymarchingBounds.makeRaymarchingBounds(for: boundingSphere)
    }
    
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingSphere.signedDistance(to: point) < current.distance else {
            return current
        }
        
        return element.signedDistance(to: point, current: current)
    }

    func makeRaymarchingBounds() -> RaymarchingBounds {
        bounds
    }
}

extension BoundingSphereRaymarchingElement {
    init<Geometry>(geometry: Geometry, material: Material) where Geometry: SignedDistanceMeasurableType & BoundableType, Geometry.Vector == RVector3D, T == GeometryRaymarchingElement<Geometry> {
        let bounds = geometry.bounds
        let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
        
        let element = GeometryRaymarchingElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingSphere: sphere)
    }

    @_transparent
    func makeBoundingSphere() -> Self {
        self
    }
}

extension BoundedRaymarchingElement {
    @_transparent
    func makeBoundingSphere() -> BoundingSphereRaymarchingElement<Self> {
        .init(element: self)
    }
}

@_transparent
func boundingSphere<T: BoundedRaymarchingElement>(@RaymarchingElementBuilder _ builder: () -> T) -> BoundingSphereRaymarchingElement<T> {
    builder().makeBoundingSphere()
}
