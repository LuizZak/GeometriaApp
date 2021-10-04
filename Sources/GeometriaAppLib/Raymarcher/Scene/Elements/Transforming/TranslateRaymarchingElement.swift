struct TranslateRaymarchingElement<T: RaymarchingElement>: RaymarchingElement {
    var element: T
    var translation: RVector3D

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        element.signedDistance(to: point - translation, current: current)
    }
}

extension TranslateRaymarchingElement: BoundedRaymarchingElement where T: BoundedRaymarchingElement {
    @_transparent
    func makeRaymarchingBounds() -> RaymarchingBounds {
        element.makeRaymarchingBounds().offsetBy(translation)
    }
}

// MARK: Helper functions

extension RaymarchingElement {
    @_transparent
    func translated(by vector: RVector3D) -> TranslateRaymarchingElement<Self> {
        .init(element: self, translation: vector)
    }

    @_transparent
    func translated(x: Double, y: Double, z: Double) -> TranslateRaymarchingElement<Self> {
        translated(by: .init(x: x, y: y, z: z))
    }

    @_transparent
    func centered(at center: RVector3D) -> TranslateRaymarchingElement<Self> where Self: BoundedRaymarchingElement {
        let bounds = self.makeRaymarchingBounds()

        return translated(by: center - bounds.center)
    }

    @_transparent
    func centered(atX x: Double) -> TranslateRaymarchingElement<Self> where Self: BoundedRaymarchingElement {
        let bounds = self.makeRaymarchingBounds()

        return translated(by: (x - bounds.center.x) * .unitX)
    }

    @_transparent
    func centered(atY y: Double) -> TranslateRaymarchingElement<Self> where Self: BoundedRaymarchingElement {
        let bounds = self.makeRaymarchingBounds()

        return translated(by: (y - bounds.center.y) * .unitY)
    }

    @_transparent
    func centered(atZ z: Double) -> TranslateRaymarchingElement<Self> where Self: BoundedRaymarchingElement {
        let bounds = self.makeRaymarchingBounds()

        return translated(by: (z - bounds.center.z) * .unitZ)
    }
}

extension TranslateRaymarchingElement {
    @_transparent
    func translated(by vector: RVector3D) -> TranslateRaymarchingElement<T> {
        .init(element: element, translation: translation + vector)
    }

    @_transparent
    func translated(x: Double, y: Double, z: Double) -> TranslateRaymarchingElement<T> {
        translated(by: .init(x: x, y: y, z: z))
    }

    @_transparent
    func centered(at center: RVector3D) -> TranslateRaymarchingElement<T> where T: BoundedRaymarchingElement {
        let bounds = element.makeRaymarchingBounds()
        return translated(by: center - bounds.center)
    }

    @_transparent
    func centered(atX x: Double) -> TranslateRaymarchingElement<T> where T: BoundedRaymarchingElement {
        let bounds = self.makeRaymarchingBounds()

        return translated(by: (x - bounds.center.x) * .unitX)
    }

    @_transparent
    func centered(atY y: Double) -> TranslateRaymarchingElement<T> where T: BoundedRaymarchingElement {
        let bounds = self.makeRaymarchingBounds()

        return translated(by: (y - bounds.center.y) * .unitY)
    }

    @_transparent
    func centered(atZ z: Double) -> TranslateRaymarchingElement<T> where T: BoundedRaymarchingElement {
        let bounds = self.makeRaymarchingBounds()

        return translated(by: (z - bounds.center.z) * .unitZ)
    }
}

@_transparent
func translated<T: RaymarchingElement>(translation: RVector3D, @RaymarchingElementBuilder _ builder: () -> T) -> TranslateRaymarchingElement<T> {
    builder().translated(by: translation)
}

@_transparent
func translated<T: RaymarchingElement>(translation: RVector3D, @RaymarchingElementBuilder _ builder: () -> TranslateRaymarchingElement<T>) -> TranslateRaymarchingElement<T> {
    builder().translated(by: translation)
}
