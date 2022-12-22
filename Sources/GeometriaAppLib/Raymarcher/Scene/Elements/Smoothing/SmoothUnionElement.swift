// Reference for distance function modifiers:
// https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
public struct SmoothUnionElement<T0: RaymarchingElement, T1: RaymarchingElement>: RaymarchingElement {
    public var id: Int = 0
    public var t0: T0
    public var t1: T1
    public var smoothSize: Double

    public init(id: Int = 0, t0: T0, t1: T1, smoothSize: Double) {
        self.id = id
        self.t0 = t0
        self.t1 = t1
        self.smoothSize = smoothSize
    }

    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let v0 = t0.signedDistance(to: point, current: current)
        let v1 = t1.signedDistance(to: point, current: current)
        
        let h = clamp(0.5 + 0.5 * (v0.distance - v1.distance) / smoothSize, min: 0.0, max: 1.0)
        let result = mix(v0, v1, factor: h).addingDistance(-smoothSize * h * (1.0 - h))

        return min(current, result)
    }
}

extension SmoothUnionElement: Element {
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        id = idFactory.makeId()

        t0.attributeIds(&idFactory)
        t1.attributeIds(&idFactory)
    }

    public func queryScene(id: Int) -> Element? {
        if let el = t0.queryScene(id: id) { return el }
        if let el = t1.queryScene(id: id) { return el }

        return nil
    }

    public func accept<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}

@_transparent
public func union<T0, T1>(smoothSize: Double, @RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> SmoothUnionElement<T0, T1> {
    let value = builder()
    return .init(t0: value.t0, t1: value.t1, smoothSize: smoothSize)
}
