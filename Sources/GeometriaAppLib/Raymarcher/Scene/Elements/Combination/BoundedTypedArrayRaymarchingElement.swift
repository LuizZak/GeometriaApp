typealias BoundedTypedArrayRaymarchingElement<T: RaymarchingBoundedElement> = BoundedTypedArrayElement<T>

extension BoundedTypedArrayRaymarchingElement: RaymarchingBoundedElement {
    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
