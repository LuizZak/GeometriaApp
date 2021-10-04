struct RepeatTranslateRaymarchingElement<T: RaymarchingElement> {
    var element: T
    var translation: RVector3D
    var count: Int
}

extension RepeatTranslateRaymarchingElement: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        element.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        element.queryScene(id: id)
    }
}

extension RepeatTranslateRaymarchingElement: RaymarchingElement {
    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        var index = 0
        while index < count {
            defer { index += 1 }
            
            let translated = point - translation * Double(index)
            let next = element.signedDistance(to: translated, current: current)

            // If a translation brought the geometry farther away from the point, 
            // the remaining translations will be farther away as well.
            if index > 0 && next.distance > current.distance {
                return current
            }

            current = next
        }
        
        return current
    }
}

extension RepeatTranslateRaymarchingElement: BoundedElement where T: BoundedElement {
    func makeBounds() -> RaymarchingBounds {
        let bounds = element.makeBounds()
        
        return bounds.union(bounds.offsetBy(translation * Double(count - 1)))
    }
}

extension RaymarchingElement {
    @_transparent
    func repeatTranslated(count: Int, translation: RVector3D) -> RepeatTranslateRaymarchingElement<Self> {
        .init(element: self, translation: translation, count: count)
    }
}

@_transparent
func repeatTranslated<T: RaymarchingElement>(count: Int, translation: RVector3D, @RaymarchingElementBuilder _ builder: () -> T) -> RepeatTranslateRaymarchingElement<T> {
    builder().repeatTranslated(count: count, translation: translation)
}
