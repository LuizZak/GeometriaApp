@resultBuilder
struct RaymarchingElementBuilder {

    // MARK: Concrete types

    static func buildExpression(_ value: RSphere3D) -> SphereRaymarchingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RSphere3D, RaymarcherMaterial)) -> SphereRaymarchingElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RAABB3D) -> AABBRaymarchingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RAABB3D, RaymarcherMaterial)) -> AABBRaymarchingElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RCylinder3D) -> CylinderRaymarchingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RCylinder3D, RaymarcherMaterial)) -> CylinderRaymarchingElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RPlane3D) -> PlaneRaymarchingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RPlane3D, RaymarcherMaterial)) -> PlaneRaymarchingElement {
        .init(geometry: value.0, material: value.1)
    }
    
    static func buildExpression(_ value: RDisk3D) -> DiskRaymarchingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RDisk3D, RaymarcherMaterial)) -> DiskRaymarchingElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildArray(_ components: [RaymarchingElement]) -> ArrayRaymarchingElement {
        .init(elements: components)
    }

    static func buildEither<T>(first component: T) -> T where T: RaymarchingElement {
        component
    }

    static func buildEither<T>(second component: T) -> T where T: RaymarchingElement {
        component
    }

    static func buildOptional<T>(_ component: T?) -> RaymarchingElement where T: RaymarchingElement {
        component ?? EmptyRaymarchingElement()
    }

    // MARK: Generic types
    
    static func buildExpression<T>(_ value: T, _ material: RaymarcherMaterial = .default) -> GeometryRaymarchingElement<T> where T: SignedDistanceMeasurableType {
        .init(geometry: value, material: material)
    }
    
    static func buildExpression<T>(_ value: T) -> T where T: RaymarchingElement {
        value
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
}

// MARK: Bounded types
extension RaymarchingElementBuilder {
    static func buildArray(_ components: [BoundedRaymarchingElement]) -> BoundedArrayRaymarchingElement {
        .init(elements: components)
    }

    static func buildArray<T>(_ components: [T]) -> BoundedTypedArrayRaymarchingElement<T> where T: BoundedRaymarchingElement {
        .init(elements: components)
    }

    static func buildBlock<T0, T1>(_ t0: T0, _ t1: T1) -> BoundedTupleRaymarchingElement2<T0, T1> {
        .init(t0: t0, t1: t1)
    }

    static func buildBlock<T0, T1, T2>(_ t0: T0, _ t1: T1, _ t2: T2) -> BoundedTupleRaymarchingElement3<T0, T1, T2> {
        .init(t0: t0, t1: t1, t2: t2)
    }

    static func buildBlock<T0, T1, T2, T3>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3) -> BoundedTupleRaymarchingElement4<T0, T1, T2, T3> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3)
    }

    static func buildBlock<T0, T1, T2, T3, T4>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4) -> BoundedTupleRaymarchingElement5<T0, T1, T2, T3, T4> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5) -> BoundedTupleRaymarchingElement6<T0, T1, T2, T3, T4, T5> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5, _ t6: T6) -> BoundedTupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5, t6: t6)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5, T6, T7>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5, _ t6: T6, _ t7: T7) -> BoundedTupleRaymarchingElement8<T0, T1, T2, T3, T4, T5, T6, T7> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5, t6: t6, t7: t7)
    }
}
