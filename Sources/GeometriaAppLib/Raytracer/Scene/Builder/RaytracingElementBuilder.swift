@resultBuilder
struct RaytracingElementBuilder {

    // MARK: Concrete types

    static func buildExpression(_ value: RSphere3D) -> SphereRaytracingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RSphere3D, RaytracingMaterial)) -> SphereRaytracingElement {
        .init(geometry: value.0, material: value.1)
    }
    
    static func buildExpression(_ value: REllipse3D) -> EllipseRaytracingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (REllipse3D, RaytracingMaterial)) -> EllipseRaytracingElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RAABB3D) -> AABBRaytracingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RAABB3D, RaytracingMaterial)) -> AABBRaytracingElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RCylinder3D) -> CylinderRaytracingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RCylinder3D, RaytracingMaterial)) -> CylinderRaytracingElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildExpression(_ value: RPlane3D) -> PlaneRaytracingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RPlane3D, RaytracingMaterial)) -> PlaneRaytracingElement {
        .init(geometry: value.0, material: value.1)
    }
    
    static func buildExpression(_ value: RDisk3D) -> DiskRaytracingElement {
        .init(geometry: value, material: .default)
    }
    static func buildExpression(_ value: (RDisk3D, RaytracingMaterial)) -> DiskRaytracingElement {
        .init(geometry: value.0, material: value.1)
    }

    static func buildEither<T>(first component: T) -> T where T: RaytracingElement {
        component
    }

    static func buildEither<T>(second component: T) -> T where T: RaytracingElement {
        component
    }

    static func buildOptional<T>(_ component: T?) -> RaytracingElement where T: RaytracingElement {
        component ?? EmptyRaytracingElement()
    }

    // MARK: Generic types
    
    static func buildExpression<T>(_ value: T, _ material: RaytracingMaterial = .default) -> GeometryRaytracingElement<T> where T: Convex3Type {
        .init(geometry: value, material: material)
    }
    
    static func buildExpression<T>(_ value: T) -> T where T: RaytracingElement {
        value
    }

    static func buildBlock() -> EmptyRaytracingElement {
        EmptyRaytracingElement()
    }

    static func buildBlock<T>(_ value: T) -> T where T: RaytracingElement {
        value
    }

    static func buildBlock<T0, T1>(_ t0: T0, _ t1: T1) -> TupleRaytracingElement2<T0, T1> {
        .init(t0: t0, t1: t1)
    }

    static func buildBlock<T0, T1, T2>(_ t0: T0, _ t1: T1, _ t2: T2) -> TupleRaytracingElement3<T0, T1, T2> {
        .init(t0: t0, t1: t1, t2: t2)
    }

    static func buildBlock<T0, T1, T2, T3>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3) -> TupleRaytracingElement4<T0, T1, T2, T3> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3)
    }

    static func buildBlock<T0, T1, T2, T3, T4>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4) -> TupleRaytracingElement5<T0, T1, T2, T3, T4> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5) -> TupleRaytracingElement6<T0, T1, T2, T3, T4, T5> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5, T6>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5, _ t6: T6) -> TupleRaytracingElement7<T0, T1, T2, T3, T4, T5, T6> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5, t6: t6)
    }

    static func buildBlock<T0, T1, T2, T3, T4, T5, T6, T7>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5, _ t6: T6, _ t7: T7) -> TupleRaytracingElement8<T0, T1, T2, T3, T4, T5, T6, T7> {
        .init(t0: t0, t1: t1, t2: t2, t3: t3, t4: t4, t5: t5, t6: t6, t7: t7)
    }
}