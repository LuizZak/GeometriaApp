// Reference for distance function modifiers:
// https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
struct IntersectionElement<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    var t0: T0
    var t1: T1

    @inlinable
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let v0 = t0.signedDistance(to: point, current: current)
        let v1 = t1.signedDistance(to: point, current: current)
        
        return min(current, max(v0, v1))
    }
}

extension IntersectionElement: Element {
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }
}

extension IntersectionElement: BoundedElement where T0: BoundedElement, T1: BoundedElement {
    // TODO: Bounds are guaranteed to be no bigger than the intersection area
    // TODO: between t0 and t1, but maybe there are better ways to generate a 
    // TODO: bounding box here.
    func makeBounds() -> ElementBounds {
        let t0Bounds = t0.makeBounds()

        return t0Bounds.intersection(t1.makeBounds()) ?? t0Bounds
    }
}

@_transparent
func intersection<T0, T1>(@RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> IntersectionElement<T0, T1> {
    let value = builder()

    return .init(t0: value.t0, t1: value.t1)
}
