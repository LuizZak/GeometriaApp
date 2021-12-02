typealias BoundedTypedArrayRaymarchingElement<T: BoundedRaymarchingElement> = BoundedTypedArrayElement<T>

extension BoundedTypedArrayRaymarchingElement {
    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
