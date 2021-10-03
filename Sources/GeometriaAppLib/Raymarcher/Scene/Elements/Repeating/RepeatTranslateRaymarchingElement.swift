struct RepeatTranslateRaymarchingElement<T: RaymarchingElement>: RaymarchingElement {
    var element: T
    var translation: RVector3D
    var count: Int

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

extension RepeatTranslateRaymarchingElement: BoundedRaymarchingElement where T: BoundedRaymarchingElement {
    func makeBounds() -> RaymarchingBounds {
        let bounds = element.makeBounds()
        
        return bounds.union(bounds.offsetBy(translation * Double(count)))
    }
}
