@_transparent
public func group<T: Element>(@ElementBuilder _ builder: () -> T) -> T {
    builder()
}
