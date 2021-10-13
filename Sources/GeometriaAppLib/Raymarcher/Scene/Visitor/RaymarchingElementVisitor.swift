protocol RaymarchingElementVisitor: ElementVisitor {
    
    // MARK: Combination

    func visit(_ element: ArrayRaymarchingElement) -> ResultType
    func visit(_ element: BoundedArrayRaymarchingElement) -> ResultType
    func visit<T>(_ element: AbsoluteRaymarchingElement<T>) -> ResultType
    func visit<T0, T1>(_ element: OperationRaymarchingElement<T0, T1>) -> ResultType

    // MARK: Repeating

    func visit<T>(_ element: ModuloRaymarchingElement<T>) -> ResultType

    // MARK: Smoothing

    func visit<T0, T1>(_ element: SmoothIntersectionElement<T0, T1>) -> ResultType
    func visit<T0, T1>(_ element: SmoothUnionElement<T0, T1>) -> ResultType
    func visit<T0, T1>(_ element: SmoothSubtractionElement<T0, T1>) -> ResultType
}
