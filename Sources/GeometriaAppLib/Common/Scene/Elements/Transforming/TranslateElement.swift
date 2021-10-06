struct TranslateElement<T: Element> {
    var element: T
    var translation: RVector3D
}

extension TranslateElement: Element {
    @_transparent
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    @_transparent
    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }
}

extension TranslateElement: BoundedElement where T: BoundedElement {
    @_transparent
    func makeBounds() -> ElementBounds {
        element.makeBounds().offsetBy(translation)
    }
}

// MARK: Helper functions

extension Element {
    @_transparent
    func translated(by vector: RVector3D) -> TranslateElement<Self> {
        .init(element: self, translation: vector)
    }

    @_transparent
    func translated(x: Double, y: Double, z: Double) -> TranslateElement<Self> {
        translated(by: .init(x: x, y: y, z: z))
    }

    @_transparent
    func centered(at center: RVector3D) -> TranslateElement<Self> where Self: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: center - bounds.center)
    }

    @_transparent
    func centered(atX x: Double) -> TranslateElement<Self> where Self: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (x - bounds.center.x) * .unitX)
    }

    @_transparent
    func centered(atY y: Double) -> TranslateElement<Self> where Self: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (y - bounds.center.y) * .unitY)
    }

    @_transparent
    func centered(atZ z: Double) -> TranslateElement<Self> where Self: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (z - bounds.center.z) * .unitZ)
    }
}

extension TranslateElement {
    @_transparent
    func translated(by vector: RVector3D) -> TranslateElement<T> {
        .init(element: element, translation: translation + vector)
    }

    @_transparent
    func translated(x: Double, y: Double, z: Double) -> TranslateElement<T> {
        translated(by: .init(x: x, y: y, z: z))
    }

    @_transparent
    func centered(at center: RVector3D) -> TranslateElement<T> where T: Element & BoundedElement {
        let bounds = element.makeBounds()
        return translated(by: center - bounds.center)
    }

    @_transparent
    func centered(atX x: Double) -> TranslateElement<T> where T: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (x - bounds.center.x) * .unitX)
    }

    @_transparent
    func centered(atY y: Double) -> TranslateElement<T> where T: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (y - bounds.center.y) * .unitY)
    }

    @_transparent
    func centered(atZ z: Double) -> TranslateElement<T> where T: Element & BoundedElement {
        let bounds = self.makeBounds()

        return translated(by: (z - bounds.center.z) * .unitZ)
    }
}

@_transparent
func translated<T: Element>(by translation: RVector3D, @ElementBuilder _ builder: () -> T) -> TranslateElement<T> {
    builder().translated(by: translation)
}

@_transparent
func translated<T: Element>(by translation: RVector3D, @ElementBuilder _ builder: () -> TranslateElement<T>) -> TranslateElement<T> {
    builder().translated(by: translation)
}
