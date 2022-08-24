/// Element that encodes a rotation in 3D space of another element.
struct RotateElement<T: Element> {
    var id: Int = 0
    var element: T
    
    var rotation: RRotationMatrix3D
    var rotationCenter: RVector3D
}

extension RotateElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }

    func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

extension RotateElement: BoundedElement where T: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        var points = element.makeBounds().asRectangle.vertices

        points = points.map {
            rotation.transformPoint($0 - rotationCenter) + rotationCenter
        }

        return ElementBounds(points: points)
    }
}

// MARK: Helper functions

extension Element {
    @_transparent
    func rotated(by rotation: RRotationMatrix3D, around rotationCenter: RVector3D) -> RotateElement<Self> {
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
    func rotated(by rotation: RRotationMatrix3D, around rotationCenter: RVector3D) -> RotateElement<T> {
        .init(element: element, rotation: self.rotation * rotation, rotationCenter: rotationCenter)
    }
}

@_transparent
func rotated<T: Element>(by rotation: RRotationMatrix3D, around rotationCenter: RVector3D, @ElementBuilder _ builder: () -> T) -> RotateElement<T> {
    builder().rotated(by: rotation, around: rotationCenter)
}

@_transparent
func rotated<T: Element>(by rotation: RRotationMatrix3D, around rotationCenter: RVector3D, @ElementBuilder _ builder: () -> RotateElement<T>) -> RotateElement<T> {
    builder().rotated(by: rotation, around: rotationCenter)
}

@_transparent
func rotatedAroundCenter<T: BoundedElement>(by rotation: RRotationMatrix3D, @ElementBuilder _ builder: () -> T) -> RotateElement<T> {
    builder().rotatedAroundCenter(by: rotation)
}
