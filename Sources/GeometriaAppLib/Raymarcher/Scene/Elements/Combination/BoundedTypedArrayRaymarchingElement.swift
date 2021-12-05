typealias BoundedTypedArrayRaymarchingElement<T: BoundedRaymarchingElement> = BoundedTypedArrayElement<T>

extension BoundedTypedArrayRaymarchingElement: BoundedRaymarchingElement {
    func accept<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        visitor.visit(self)
    }
}
