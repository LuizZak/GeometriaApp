@_transparent
func group<T: RaymarchingElement>(@RaymarchingElementBuilder _ builder: () -> T) -> T {
    builder()
}
