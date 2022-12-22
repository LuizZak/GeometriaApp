#if canImport(Geometria)
import Geometria
#endif

public struct BoundingSphereElement<T: Element> {
    public var id: Element.Id = 0
    public var element: T
    public var boundingSphere: RSphere3D
    
    public init(element: T, boundingSphere: RSphere3D) {
        self.element = element
        self.boundingSphere = boundingSphere
    }
}

extension BoundingSphereElement {
    public init<Geometry>(geometry: Geometry, material: Int) where Geometry: BoundableType, Geometry.Vector == RVector3D, T == GeometryElement<Geometry> {
        let bounds = geometry.bounds
        let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
        
        let element = GeometryElement(geometry: geometry, material: material)
        
        self.init(element: element, boundingSphere: sphere)
    }

    @_transparent
    public func makeBoundingSphere() -> Self {
        self
    }
}

extension BoundingSphereElement: Element {
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

extension BoundingSphereElement: BoundedElement {
    @_transparent
    public func makeBounds() -> ElementBounds {
        ElementBounds.makeBounds(for: boundingSphere)
    }
}

extension BoundedElement {
    @_transparent
    public func makeBoundingSphere() -> BoundingSphereElement<Self> {
        .init(element: self)
    }
}

@_transparent
public func boundingSphere<T: BoundedElement>(@ElementBuilder _ builder: () -> T) -> BoundingSphereElement<T> {
    builder().makeBoundingSphere()
}
