public protocol ElementVisitor {
    associatedtype ResultType

    // MARK: Generic elements

    func visit<T>(_ element: borrowing T) -> ResultType where T: BoundedElement
    func visit<T>(_ element: borrowing T) -> ResultType where T: Element

    // MARK: Basic

    func visit(_ element: borrowing AABBElement) -> ResultType
    func visit(_ element: borrowing CubeElement) -> ResultType
    func visit(_ element: borrowing CylinderElement) -> ResultType
    func visit(_ element: borrowing DiskElement) -> ResultType
    func visit(_ element: borrowing EllipseElement) -> ResultType
    func visit(_ element: borrowing EmptyElement) -> ResultType
    func visit<T>(_ element: borrowing GeometryElement<T>) -> ResultType
    func visit(_ element: borrowing LineSegmentElement) -> ResultType
    func visit(_ element: borrowing PlaneElement) -> ResultType
    func visit(_ element: borrowing SphereElement) -> ResultType
    func visit(_ element: borrowing TorusElement) -> ResultType
    func visit(_ element: borrowing HyperplaneElement) -> ResultType

    // MARK: Bounding

    func visit<T>(_ element: borrowing BoundingBoxElement<T>) -> ResultType
    func visit<T>(_ element: borrowing BoundingSphereElement<T>) -> ResultType

    // MARK: Combination

    func visit<T>(_ element: borrowing BoundedTypedArrayElement<T>) -> ResultType
    func visit<T0, T1>(_ element: borrowing IntersectionElement<T0, T1>) -> ResultType
    func visit<T0, T1>(_ element: borrowing SubtractionElement<T0, T1>) -> ResultType
    func visit<T>(_ element: borrowing TypedArrayElement<T>) -> ResultType
    func visit<T0, T1>(_ element: borrowing UnionElement<T0, T1>) -> ResultType

    // MARK: Repeating

    func visit<T>(_ element: borrowing RepeatTranslateElement<T>) -> ResultType

    // MARK: Transforming
borrowing 
    func visit<T>(_ element: borrowing RotateElement<T>) -> ResultType
    func visit<T>(_ element: borrowing ScaleElement<T>) -> ResultType
    func visit<T>(_ element: borrowing TranslateElement<T>) -> ResultType

    // MARK: Tuple Elements

    #if VARIADIC_TUPLE_ELEMENT

    func visit<T>(_ element: borrowing T) -> ResultType where T: TupleElementType

    /* TODO: Currently crashing compiler (possibly https://github.com/apple/swift/issues/67906) 
    func visit<each T>(_ element: repeat TupleElement<each T>) -> ResultType
    func visit<each T>(_ element: repeat BoundedTupleElement<each T>) -> ResultType
    */

    #endif
    
    func visit<T0, T1>(
        _ element: borrowing TupleElement2<T0, T1>
    ) -> ResultType
    func visit<T0, T1>(
        _ element: borrowing BoundedTupleElement2<T0, T1>
    ) -> ResultType
    
    func visit<T0, T1, T2>(
        _ element: borrowing TupleElement3<T0, T1, T2>
    ) -> ResultType
    func visit<T0, T1, T2>(
        _ element: borrowing BoundedTupleElement3<T0, T1, T2>
    ) -> ResultType
    
    func visit<T0, T1, T2, T3>(
        _ element: borrowing TupleElement4<T0, T1, T2, T3>
    ) -> ResultType
    func visit<T0, T1, T2, T3>(
        _ element: borrowing BoundedTupleElement4<T0, T1, T2, T3>
    ) -> ResultType

    func visit<T0, T1, T2, T3, T4>(
        _ element: borrowing TupleElement5<T0, T1, T2, T3, T4>
    ) -> ResultType
    func visit<T0, T1, T2, T3, T4>(
        _ element: borrowing BoundedTupleElement5<T0, T1, T2, T3, T4>
    ) -> ResultType
    
    func visit<T0, T1, T2, T3, T4, T5>(
        _ element: borrowing TupleElement6<T0, T1, T2, T3, T4, T5>
    ) -> ResultType
    func visit<T0, T1, T2, T3, T4, T5>(
        _ element: borrowing BoundedTupleElement6<T0, T1, T2, T3, T4, T5>
    ) -> ResultType
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(
        _ element: borrowing TupleElement7<T0, T1, T2, T3, T4, T5, T6>
    ) -> ResultType
    func visit<T0, T1, T2, T3, T4, T5, T6>(
        _ element: borrowing BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>
    ) -> ResultType
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(
        _ element: borrowing TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>
    ) -> ResultType
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(
        _ element: borrowing BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>
    ) -> ResultType
}
