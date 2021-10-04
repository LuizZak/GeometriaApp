struct BoundingSphereElement<T: Element> {
    var element: T
    var boundingSphere: RSphere3D
    
    init(element: T, boundingSphere: RSphere3D) {
        self.element = element
        self.boundingSphere = boundingSphere
    }
    
    func makeRaymarchingBounds() -> ElementBounds {
        ElementBounds.makeBounds(for: boundingSphere)
    }
}

extension BoundingSphereElement {
    init<Geometry>(geometry: Geometry, material: Material) where Geometry: BoundableType, Geometry.Vector == RVector3D, T == GeometryElement<Geometry> {
        let bounds = geometry.bounds
        let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
        
        let element = GeometryElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingSphere: sphere)
    }

    @_transparent
    func makeBoundingSphere() -> Self {
        self
    }
}

extension BoundingSphereElement: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }
}

extension BoundingSphereElement: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        ElementBounds.makeBounds(for: boundingSphere)
    }
}

extension BoundedElement {
    @_transparent
    func makeBoundingSphere() -> BoundingSphereElement<Self> {
        .init(element: self)
    }
}

@_transparent
func boundingSphere<T: BoundedElement>(@ElementBuilder _ builder: () -> T) -> BoundingSphereElement<T> {
    builder().makeBoundingSphere()
}
