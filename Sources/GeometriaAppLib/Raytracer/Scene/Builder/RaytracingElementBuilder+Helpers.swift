@_transparent
func group<T: RaytracingElement>(@RaytracingElementBuilder _ builder: () -> T) -> T {
    builder()
}
