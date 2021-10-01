@resultBuilder
struct RaymarchingSceneBuilder {
    static func buildExpression<T>(_ value: T) -> GeometryRaymarchingElement<T> where T: SignedDistanceMeasurableType {
        .init(geometry: value)
    }

    static func buildBlock() -> EmptyRaymarchingElement {
        EmptyRaymarchingElement()
    }

    static func buildBlock<T>(_ value: T) -> T where T: RaymarchingElement {
        value
    }

    static func buildBlock<T0, T1>(_ t0: T0, _ t1: T1) -> TupleRaymarchingElement2<T0, T1> {
        .init(t0: t0, t1: t1)
    }

    static func buildBlock<T0, T1, T2>(_ t0: T0, _ t1: T1, _ t2: T2) -> TupleRaymarchingElement3<T0, T1, T2> {
        .init(t0: t0, t1: t1, t2: t2)
    }

    static func buildBlock<T0, T1, T2, T3>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3) -> TupleRaymarchingElement4<T0, T1, T2, T3> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3)
    }

    static func buildBlock<T0, T1, T2, T3, T4>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4) -> TupleRaymarchingElement5<T0, T1, T2, T3, T4> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5) -> TupleRaymarchingElement6<T0, T1, T2, T3, T4, T5> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5, _ t6: T6) -> TupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5, t6: t6)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5, T6, T7>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5, _ t6: T6, _ t7: T7) -> TupleRaymarchingElement8<T0, T1, T2, T3, T4, T5, T6, T7> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5, t6: t6, t7: t7)
    }

    static func buildFinalResult<T: RaymarchingElement>(_ element: T) -> RaymarchingScene<T> {
        .init(root: element, skyColor: .cornflowerBlue)
    }
}

extension RaymarchingSceneBuilder {
    static func makeScene<T>(@RaymarchingSceneBuilder _ builder: () -> T) -> T where T: RaymarchingSceneType {
        builder()
    }
}
