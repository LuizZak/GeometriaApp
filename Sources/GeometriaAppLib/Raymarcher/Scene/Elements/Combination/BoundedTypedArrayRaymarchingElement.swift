public typealias BoundedTypedArrayRaymarchingElement<T: RaymarchingBoundedElement> = BoundedTypedArrayElement<T>

extension BoundedTypedArrayRaymarchingElement: RaymarchingBoundedElement {
    public func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
