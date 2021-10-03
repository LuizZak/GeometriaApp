func group<T: RaymarchingElement>(@RaymarchingElementBuilder _ builder: () -> T) -> T {
    builder()
}

func boundingBox<T: BoundedRaymarchingElement>(@RaymarchingElementBuilder _ builder: () -> T) -> BoundingBoxRaymarchingElement<T> {
    .init(element: builder())
}

func boundingSphere<T: BoundedRaymarchingElement>(@RaymarchingElementBuilder _ builder: () -> T) -> BoundingSphereRaymarchingElement<T> {
    .init(element: builder())
}

func repeatTranslate<T: RaymarchingElement>(count: Int, translation: RVector3D, @RaymarchingElementBuilder _ builder: () -> T) -> RepeatTranslateRaymarchingElement<T> {
    .init(element: builder(), translation: translation, count: count)
}

func repeatTranslate<T: BoundedRaymarchingElement>(count: Int, translation: RVector3D, @RaymarchingElementBuilder _ builder: () -> T) -> RepeatTranslateBoundedRaymarchingElement<T> {
    .init(element: builder(), translation: translation, count: count)
}

// Reference for distance function modifiers:
// https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

// MARK: Basic operations

func intersection<T0, T1>(@RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> IntersectionElement<T0, T1> {
    let value = builder()

    return .init(t0: value.t0, t1: value.t1)
}

func subtraction<T0, T1>(@RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> SubtractionElement<T0, T1> {
    let value = builder()

    return .init(t0: value.t0, t1: value.t1)
}

// MARK: Basic operations - smoothed

func union<T0, T1>(smoothSize: Double, @RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> SmoothUnionElement<T0, T1> {
    let value = builder()
    return .init(t0: value.t0, t1: value.t1, smoothSize: smoothSize)
}

func intersection<T0, T1>(smoothSize: Double, @RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> SmoothIntersectionElement<T0, T1> {
    let value = builder()
    return .init(t0: value.t0, t1: value.t1, smoothSize: smoothSize)
}

func subtraction<T0, T1>(smoothSize: Double, @RaymarchingElementBuilder _ builder: () -> TupleRaymarchingElement2<T0, T1>) -> SmoothSubtractionElement<T0, T1> {
    let value = builder()
    return .init(t0: value.t0, t1: value.t1, smoothSize: smoothSize)
}
