#if canImport(Geometria)
import Geometria
#endif

/// Element that encodes a rotation in 3D space of another element.
struct RotateElement<T: Element> {
    var id: Element.Id = 0
    var element: T
    
    var rotation: Transform3x3
    var rotationCenter: RVector3D
    
    internal init(
        id: Int = 0,
        element: T,
        rotation: Transform3x3,
        rotationCenter: RVector3D
    ) {
        self.id = id
        self.element = element
        self.rotation = rotation
        self.rotationCenter = rotationCenter
    }
    
    internal init(
        id: Int = 0,
        element: T,
        rotation: RRotationMatrix3D,
        rotationCenter: RVector3D
    ) {
        self.id = id
        self.element = element
        self.rotation = .init(rotation)
        self.rotationCenter = rotationCenter
    }
}

extension RotateElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Element.Id) -> Element? {
        if id == self.id { return self }
        
        return element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension RotateElement: BoundedElement where T: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        element.makeBounds().rotatedBy(rotation.m, around: rotationCenter)
    }
}

// MARK: Helper functions

extension Element {
    @_transparent
    func rotatedBy(_ rotation: RRotationMatrix3D, around rotationCenter: RVector3D) -> RotateElement<Self> {
        .init(element: self, rotation: rotation, rotationCenter: rotationCenter)
    }
}

extension BoundedElement {
    @_transparent
    func rotatedAroundCenter(by rotation: RRotationMatrix3D) -> RotateElement<Self> {
        .init(element: self, rotation: rotation, rotationCenter: makeBounds().center)
    }
}

extension RotateElement {
    @_transparent
    func rotatedBy(_ rotation: RRotationMatrix3D, around rotationCenter: RVector3D) -> RotateElement<T> {
        .init(element: element, rotation: self.rotation * rotation, rotationCenter: rotationCenter)
    }
}

@_transparent
func rotated<T: Element>(by rotation: RRotationMatrix3D, around rotationCenter: RVector3D, @ElementBuilder _ builder: () -> T) -> RotateElement<T> {
    builder().rotatedBy(rotation, around: rotationCenter)
}

@_transparent
func rotated<T: Element>(by rotation: RRotationMatrix3D, around rotationCenter: RVector3D, @ElementBuilder _ builder: () -> RotateElement<T>) -> RotateElement<T> {
    builder().rotatedBy(rotation, around: rotationCenter)
}

@_transparent
func rotatedAroundCenter<T: BoundedElement>(by rotation: RRotationMatrix3D, @ElementBuilder _ builder: () -> T) -> RotateElement<T> {
    builder().rotatedAroundCenter(by: rotation)
}
