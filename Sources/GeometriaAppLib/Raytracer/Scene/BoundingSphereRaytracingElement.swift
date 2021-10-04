struct BoundingSphereRaytracingElement<T>: BoundedRaytracingElement where T: RaytracingElement {
    var element: T
    var boundingSphere: RSphere3D
    var bounds: RaytracingBounds
    
    init(element: T, boundingSphere: RSphere3D) {
        self.element = element
        self.boundingSphere = boundingSphere
        bounds = RaytracingBounds.makeBounds(for: boundingSphere)
    }
    
    func raycast(query: RayQuery) -> RayQuery {
        element.raycast(query: query)
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        element.raycast(query: query, results: &results)
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    /// Returns an item on this raytracing element matching a specified id.
    /// Returns `nil` if no element with the given ID was found on this element
    /// or any of its sub-elements.
    func queryScene(id: Int) -> RaytracingElement? {
        element.queryScene(id: id)
    }

    func makeBounds() -> RaytracingBounds {
        bounds
    }
}

extension BoundingSphereRaytracingElement {
    init<Geometry>(geometry: Geometry, material: RaytracingMaterial) where Geometry: SignedDistanceMeasurableType & BoundableType, Geometry.Vector == RVector3D, T == GeometryRaytracingElement<Geometry> {
        let bounds = geometry.bounds
        let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
        
        let element = GeometryRaytracingElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingSphere: sphere)
    }

    @_transparent
    func makeBoundingSphere() -> Self {
        self
    }
}

extension BoundedRaytracingElement {
    @_transparent
    func makeBoundingSphere() -> BoundingSphereRaytracingElement<Self> {
        .init(element: self)
    }
}

@_transparent
func boundingSphere<T: BoundedRaytracingElement>(@RaytracingElementBuilder _ builder: () -> T) -> BoundingSphereRaytracingElement<T> {
    builder().makeBoundingSphere()
}
