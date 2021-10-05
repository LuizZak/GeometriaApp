typealias BoundedTypedArrayElement<T: BoundedElement> = TypedArrayElement<T>

extension BoundedTypedArrayElement: BoundedElement {
    @inlinable
    func makeBounds() -> ElementBounds {
        elements.map { $0.makeBounds() }.reduce(.zero) { $0.union($1) }
    }
}