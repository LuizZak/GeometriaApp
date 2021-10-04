@resultBuilder
struct ElementBuilder {

    // MARK: Concrete types

    static func buildExpression(_ value: RSphere3D) -> SphereElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RSphere3D, Material)) -> SphereElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RAABB3D) -> AABBElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RAABB3D, Material)) -> AABBElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RCylinder3D) -> CylinderElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RCylinder3D, Material)) -> CylinderElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RPlane3D) -> PlaneElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RPlane3D, Material)) -> PlaneElement {
        .init(geometry: value.0, material: value.1)
    }
    
    static func buildExpression(_ value: RDisk3D) -> DiskElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RDisk3D, Material)) -> DiskElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildArray<T>(_ components: [T]) -> TypedArrayElement<T> {
        .init(elements: components)
    }

    static func buildEither<T>(first component: T) -> T {
        component
    }

    static func buildEither<T>(second component: T) -> T {
        component
    }

    static func buildOptional<T>(_ component: T?) -> Any {
        component ?? EmptyElement()
    }

    // MARK: Generic types
    
    static func buildExpression<T>(_ value: T, _ material: Material = .default) -> GeometryElement<T> {
        .init(geometry: value, material: material)
    }
    
    static func buildExpression<T>(_ value: T) -> T {
        value
    }

    static func buildBlock() -> EmptyElement {
        EmptyElement()
    }

    static func buildBlock<T>(_ value: T) -> T {
        value
    }

    static func buildBlock<T0, T1>(_ t0: T0, _ t1: T1) -> TupleElement2<T0, T1> {
        .init(t0: t0, t1: t1)
    }

    static func buildBlock<T0, T1, T2>(_ t0: T0, _ t1: T1, _ t2: T2) -> TupleElement3<T0, T1, T2> {
        .init(t0: t0, t1: t1, t2: t2)
    }

    static func buildBlock<T0, T1, T2, T3>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3) -> TupleElement4<T0, T1, T2, T3> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3)
    }

    static func buildBlock<T0, T1, T2, T3, T4>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4) -> TupleElement5<T0, T1, T2, T3, T4> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5) -> TupleElement6<T0, T1, T2, T3, T4, T5> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5, _ t6: T6) -> TupleElement7<T0, T1, T2, T3, T4, T5, T6> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5, t6: t6)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5, T6, T7>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5, _ t6: T6, _ t7: T7) -> TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5, t6: t6, t7: t7)
    }
}

// MARK: Bounded types
extension ElementBuilder {
    static func buildArray<T>(_ components: [T]) -> BoundedTypedArrayElement<T> where T: BoundedElement {
        .init(elements: components)
    }
}
