struct BoundedArrayRaymarchingElement: BoundedRaymarchingElement {
    var elements: [BoundedRaymarchingElement]

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        for el in elements {
            current = el.signedDistance(to: point, current: current)
        }
        
        return current
    }

    func makeRaymarchingBounds() -> RaymarchingBounds {
        elements.map { $0.makeRaymarchingBounds() }.reduce(.zero) { $0.union($1) }
    }
}

struct BoundedTypedArrayRaymarchingElement<T: BoundedRaymarchingElement>: BoundedRaymarchingElement {
    var elements: [T]

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        for el in elements {
            current = el.signedDistance(to: point, current: current)
        }
        
        return current
    }

    func makeRaymarchingBounds() -> RaymarchingBounds {
        elements.map { $0.makeRaymarchingBounds() }.reduce(.zero) { $0.union($1) }
    }
}
