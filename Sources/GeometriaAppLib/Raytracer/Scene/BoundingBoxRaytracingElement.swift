struct BoundingBoxRaytracingElement<T>: BoundedRaytracingElement where T: RaytracingElement {
    var element: T
    var boundingBox: RAABB3D
    var bounds: RaytracingBounds
    
    init(element: T, boundingBox: RAABB3D) {
        self.element = element
        self.boundingBox = boundingBox
        bounds = RaytracingBounds.makeRaytracingBounds(for: boundingBox)
    }
    
    func raycast(query: RayQuery) -> RayQuery {
        guard intersects(query: query) else {
            return query
        }

        return element.raycast(query: query)
    }

    func raycast(query: RayQuery, results: inout [RayHit]) {
        guard intersects(query: query) else {
            return
        }

        element.raycast(query: query, results: &results)
    }

    private func intersects(query: RayQuery) -> Bool {
        if let aabb = query.rayAABB, !bounds.intersects(aabb) {
            return false
        }

        return query.rayMagnitudeSquared.isFinite 
            ? boundingBox.intersects(line: query.lineSegment)
            : boundingBox.intersects(line: query.ray)
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

    func makeRaytracingBounds() -> RaytracingBounds {
        bounds
    }
}

extension BoundingBoxRaytracingElement {
    init<Geometry>(geometry: Geometry, material: Material) where Geometry: SignedDistanceMeasurableType & BoundableType, Geometry.Vector == RVector3D, T == GeometryRaytracingElement<Geometry> {
        let element = GeometryRaytracingElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingBox: geometry.bounds)
    }

    @_transparent
    func makeBoundingBox() -> Self {
        self
    }
}

extension RaytracingElement {
    @_transparent
    func withBoundingBox(box: RAABB3D) -> BoundingBoxRaytracingElement<Self> {
        .init(element: self, boundingBox: box)
    }
}

extension BoundedRaytracingElement {
    @_transparent
    func makeBoundingBox() -> BoundingBoxRaytracingElement<Self> {
        .init(element: self)
    }
}

@_transparent
func boundingBox<T: BoundedRaytracingElement>(@RaytracingElementBuilder _ builder: () -> T) -> BoundingBoxRaytracingElement<T> {
    builder().makeBoundingBox()
}
