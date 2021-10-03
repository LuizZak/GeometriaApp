struct BoundedArrayRaymarchingElement: BoundedRaymarchingElement {
    var elements: [BoundedRaymarchingElement]

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        for el in elements {
            current = el.signedDistance(to: point, current: current)
        }
        
        return current
    }

    func makeBounds() -> RaymarchingBounds {
        elements.map { $0.makeBounds() }.reduce(.zero) { $0.union($1) }
    }
}

struct BoundedTypedArrayRaymarchingElement<T: BoundedRaymarchingElement>: BoundedRaymarchingElement {
    var elements: [T]

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        for el in elements {
            current = el.signedDistance(to: point, current: current)
        }
        
        return current
    }

    func makeBounds() -> RaymarchingBounds {
        elements.map { $0.makeBounds() }.reduce(.zero) { $0.union($1) }
    }
}
