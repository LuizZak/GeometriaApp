public typealias BoundedTypedArrayElement<T: BoundedElement> = TypedArrayElement<T>

extension BoundedTypedArrayElement: BoundedElement {
    @inlinable
    public func makeBounds() -> ElementBounds {
        elements.map { $0.makeBounds() }.reduce(.zero) { $0.union($1) }
    }
}
