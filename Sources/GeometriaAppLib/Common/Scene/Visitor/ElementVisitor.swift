public protocol ElementVisitor {
    associatedtype ResultType

    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement
    func visit<T>(_ element: T) -> ResultType where T: Element

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType
    func visit(_ element: CubeElement) -> ResultType
    func visit(_ element: CylinderElement) -> ResultType
    func visit(_ element: DiskElement) -> ResultType
    func visit(_ element: EllipseElement) -> ResultType
    func visit(_ element: EmptyElement) -> ResultType
    func visit<T>(_ element: GeometryElement<T>) -> ResultType
    func visit(_ element: LineSegmentElement) -> ResultType
    func visit(_ element: PlaneElement) -> ResultType
    func visit(_ element: SphereElement) -> ResultType
    func visit(_ element: TorusElement) -> ResultType
    func visit(_ element: HyperplaneElement) -> ResultType

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType

    // MARK: Transforming

    func visit<T>(_ element: RotateElement<T>) -> ResultType
    func visit<T>(_ element: ScaleElement<T>) -> ResultType
    func visit<T>(_ element: TranslateElement<T>) -> ResultType

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType
}
