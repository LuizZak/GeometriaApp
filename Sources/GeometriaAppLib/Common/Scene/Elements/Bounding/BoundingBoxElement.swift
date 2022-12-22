#if canImport(Geometria)
import Geometria
#endif

public struct BoundingBoxElement<T: Element> {
    public var id: Element.Id = 0
    public var element: T
    public var boundingBox: RAABB3D
    
    public init(element: T, boundingBox: RAABB3D) {
        self.element = element
        self.boundingBox = boundingBox
    }
}

extension BoundingBoxElement {
    public init<Geometry>(geometry: Geometry, material: Int) where Geometry: BoundableType, Geometry.Vector == RVector3D, T == GeometryElement<Geometry> {
        let element = GeometryElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingBox: geometry.bounds)
    }

    @_transparent
    public func makeBoundingBox() -> Self {
        self
    }
}

extension BoundingBoxElement: Element {
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    public func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        
        return element.queryScene(id: id)
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension BoundingBoxElement: BoundedElement {
    @_transparent
    public func makeBounds() -> ElementBounds {
        ElementBounds.makeBounds(for: boundingBox)
    }
}

extension BoundedElement {
    @_transparent
    public func makeBoundingBox() -> BoundingBoxElement<Self> {
        .init(element: self)
    }
}

@_transparent
public func boundingBox<T: BoundedElement>(@ElementBuilder _ builder: () -> T) -> BoundingBoxElement<T> {
    builder().makeBoundingBox()
}
