struct ScaleElement<T: Element> {
    var element: T
    var scaling: Double
    var scalingCenter: RVector3D
}

extension ScaleElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }
}

extension ScaleElement: BoundedElement where T: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        element.makeBounds().scaledBy(scaling, around: scalingCenter)
    }
}

// MARK: Helper functions

extension Element {
    @_transparent
    func scaled(by factor: Double, around scalingCenter: RVector3D) -> ScaleElement<Self> {
        .init(element: self, scaling: factor, scalingCenter: scalingCenter)
    }
}

extension BoundedElement {
    @_transparent
    func scaledAroundCenter(by factor: Double) -> ScaleElement<Self> {
        .init(element: self, scaling: factor, scalingCenter: makeBounds().center)
    }
}

extension ScaleElement {
    @_transparent
    func scaled(by vector: Double, around scalingCenter: RVector3D) -> ScaleElement<T> {
        .init(element: element, scaling: scaling * vector, scalingCenter: scalingCenter)
    }
}

@_transparent
func scaled<T: Element>(by scaling: Double, around scalingCenter: RVector3D, @ElementBuilder _ builder: () -> T) -> ScaleElement<T> {
    builder().scaled(by: scaling, around: scalingCenter)
}

@_transparent
func scaled<T: Element>(by scaling: Double, around scalingCenter: RVector3D, @ElementBuilder _ builder: () -> ScaleElement<T>) -> ScaleElement<T> {
    builder().scaled(by: scaling, around: scalingCenter)
}

@_transparent
func scaledAroundCenter<T: BoundedElement>(by scaling: Double, @ElementBuilder _ builder: () -> T) -> ScaleElement<T> {
    builder().scaledAroundCenter(by: scaling)
}
