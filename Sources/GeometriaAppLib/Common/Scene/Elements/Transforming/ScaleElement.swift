public struct ScaleElement<T: Element> {
    public var id: Element.Id = 0
    public var element: T
    public var scaling: Double
    public var scalingCenter: RVector3D

    public init(id: Element.Id = 0, element: T, scaling: Double, scalingCenter: RVector3D) {
        self.id = id
        self.element = element
        self.scaling = scaling
        self.scalingCenter = scalingCenter
    }
}

extension ScaleElement: Element {
    @_transparent
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    @_transparent
    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        
        return element.queryScene(id: id)
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension ScaleElement: BoundedElement where T: BoundedElement {
    @_transparent
    public func makeBounds() -> ElementBounds {
        element.makeBounds().scaledBy(scaling, around: scalingCenter)
    }
}

// MARK: Helper functions

extension Element {
    @_transparent
    public func scaled(by factor: Double, around scalingCenter: RVector3D) -> ScaleElement<Self> {
        .init(element: self, scaling: factor, scalingCenter: scalingCenter)
    }
}

extension BoundedElement {
    @_transparent
    public func scaledAroundCenter(by factor: Double) -> ScaleElement<Self> {
        .init(element: self, scaling: factor, scalingCenter: makeBounds().center)
    }
}

extension ScaleElement {
    @_transparent
    public func scaled(by vector: Double, around scalingCenter: RVector3D) -> ScaleElement<T> {
        .init(element: element, scaling: scaling * vector, scalingCenter: scalingCenter)
    }
}

@_transparent
public func scaled<T: Element>(by scaling: Double, around scalingCenter: RVector3D, @ElementBuilder _ builder: () -> T) -> ScaleElement<T> {
    builder().scaled(by: scaling, around: scalingCenter)
}

@_transparent
public func scaled<T: Element>(by scaling: Double, around scalingCenter: RVector3D, @ElementBuilder _ builder: () -> ScaleElement<T>) -> ScaleElement<T> {
    builder().scaled(by: scaling, around: scalingCenter)
}

@_transparent
public func scaledAroundCenter<T: BoundedElement>(by scaling: Double, @ElementBuilder _ builder: () -> T) -> ScaleElement<T> {
    builder().scaledAroundCenter(by: scaling)
}
