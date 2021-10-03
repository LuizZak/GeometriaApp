struct BoundingBoxRaymarchingElement<T>: BoundedRaymarchingElement where T: RaymarchingElement {
    var element: T
    var boundingBox: RAABB3D
    var bounds: RaymarchingBounds
    
    init(element: T, boundingBox: RAABB3D) {
        self.element = element
        self.boundingBox = boundingBox
        bounds = RaymarchingBounds.makeBounds(for: boundingBox)
    }
    
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        guard boundingBox.signedDistance(to: point) < current.distance else {
            return current
        }
        
        return element.signedDistance(to: point, current: current)
    }

    func makeBounds() -> RaymarchingBounds {
        bounds
    }
}

extension BoundingBoxRaymarchingElement {
    init<Geometry>(geometry: Geometry, material: RaymarcherMaterial) where Geometry: SignedDistanceMeasurableType & BoundableType, Geometry.Vector == RVector3D, T == GeometryRaymarchingElement<Geometry> {
        let element = GeometryRaymarchingElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingBox: geometry.bounds)
    }
}
