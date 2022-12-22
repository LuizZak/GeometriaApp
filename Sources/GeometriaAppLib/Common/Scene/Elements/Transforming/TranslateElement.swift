#if canImport(Geometria)
import Geometria
#endif

public struct TranslateElement<T: Element> {
    public var id: Element.Id = 0
    public var element: T
    public var translation: RVector3D

    public init(id: Element.Id = 0, element: T, translation: RVector3D) {
        self.id = id
        self.element = element
        self.translation = translation
    }
}

extension TranslateElement: Element {
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

extension TranslateElement: BoundedElement where T: BoundedElement {
    @_transparent
    public func makeBounds() -> ElementBounds {
        element.makeBounds().offsetBy(translation)
    }
}

// MARK: Helper functions

extension Element {
    @_transparent
    public func translated(by vector: RVector3D) -> TranslateElement<Self> {
        .init(element: self, translation: vector)
    }

    @_transparent
    public func translated(x: Double, y: Double, z: Double) -> TranslateElement<Self> {
        translated(by: .init(x: x, y: y, z: z))
    }

    @_transparent
    public func centered(at center: RVector3D) -> TranslateElement<Self> where Self: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: center - bounds.center)
    }

    @_transparent
    public func centered(atX x: Double) -> TranslateElement<Self> where Self: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (x - bounds.center.x) * .unitX)
    }

    @_transparent
    public func centered(atY y: Double) -> TranslateElement<Self> where Self: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (y - bounds.center.y) * .unitY)
    }

    @_transparent
    public func centered(atZ z: Double) -> TranslateElement<Self> where Self: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (z - bounds.center.z) * .unitZ)
    }
}

extension TranslateElement {
    @_transparent
    public func translated(by vector: RVector3D) -> TranslateElement<T> {
        .init(element: element, translation: translation + vector)
    }

    @_transparent
    public func translated(x: Double, y: Double, z: Double) -> TranslateElement<T> {
        translated(by: .init(x: x, y: y, z: z))
    }

    @_transparent
    public func centered(at center: RVector3D) -> TranslateElement<T> where T: Element & BoundedElement {
        let bounds = element.makeBounds()
        return translated(by: center - bounds.center)
    }

    @_transparent
    public func centered(atX x: Double) -> TranslateElement<T> where T: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (x - bounds.center.x) * .unitX)
    }

    @_transparent
    public func centered(atY y: Double) -> TranslateElement<T> where T: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (y - bounds.center.y) * .unitY)
    }

    @_transparent
    public func centered(atZ z: Double) -> TranslateElement<T> where T: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (z - bounds.center.z) * .unitZ)
    }
}

// MARK: - Global functions

@_transparent
public func translated<T: Element>(by translation: RVector3D, @ElementBuilder _ builder: () -> T) -> TranslateElement<T> {
    builder().translated(by: translation)
}

@_transparent
public func translated<T: Element>(by translation: RVector3D, @ElementBuilder _ builder: () -> TranslateElement<T>) -> TranslateElement<T> {
    builder().translated(by: translation)
}


@_transparent
public func translated<T: Element>(x: Double, y: Double, z: Double, @ElementBuilder _ builder: () -> T) -> TranslateElement<T> {
    builder().translated(x: x, y: y, z: z)
}

@_transparent
public func translated<T: Element>(x: Double, y: Double, z: Double, @ElementBuilder _ builder: () -> TranslateElement<T>) -> TranslateElement<T> {
    builder().translated(x: x, y: y, z: z)
}
