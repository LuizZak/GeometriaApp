struct BoundingBoxElement<T: Element> {
    var element: T
    var boundingBox: RAABB3D
    
    init(element: T, boundingBox: RAABB3D) {
        self.element = element
        self.boundingBox = boundingBox
    }
}

extension BoundingBoxElement {
    init<Geometry>(geometry: Geometry, material: Int) where Geometry: BoundableType, Geometry.Vector == RVector3D, T == GeometryElement<Geometry> {
        let element = GeometryElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingBox: geometry.bounds)
    }

    @_transparent
    func makeBoundingBox() -> Self {
        self
    }
}

extension BoundingBoxElement: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }
}

extension BoundingBoxElement: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        ElementBounds.makeBounds(for: boundingBox)
    }
}

extension BoundedElement {
    @_transparent
    func makeBoundingBox() -> BoundingBoxElement<Self> {
        .init(element: self)
    }
}

@_transparent
func boundingBox<T: BoundedElement>(@ElementBuilder _ builder: () -> T) -> BoundingBoxElement<T> {
    builder().makeBoundingBox()
}