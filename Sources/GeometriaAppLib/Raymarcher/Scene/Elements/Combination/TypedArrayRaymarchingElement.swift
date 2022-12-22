public typealias TypedArrayRaymarchingElement<T: RaymarchingElement> = TypedArrayElement<T>

extension TypedArrayRaymarchingElement: RaymarchingElement {
    @inlinable
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        var current = current

        for el in elements {
            current = el.signedDistance(to: point, current: current)
        }
        
        return current
    }

    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
