#if canImport(Geometria)
import Geometria
#endif

class ProcessingSceneElementProvider {
    var scene: SceneType
    
    init(scene: SceneType) {
        self.scene = scene
    }
    
    func findElement(id: Int) -> FoundElement? {
        let visitor = Visitor(id: id)
        
        return scene.walk(visitor)
    }
}

struct FoundElement {
    var transform: RMatrix4x4?
    var element: ElementKind
    
    func transformed(by matrix: RMatrix4x4, prepend: Bool = false) -> Self {
        var copy = self
        let prevTransform = copy.transform ?? .identity
        
        if prepend {
            copy.transform = matrix * prevTransform
        } else {
            copy.transform = prevTransform * matrix
        }
        
        return copy
    }
    
    static func element(_ kind: ElementKind) -> Self {
        Self(element: kind)
    }
    
    enum ElementKind {
        case sphere(RSphere3D)
        case aabb(RAABB3D)
        case cylinder(RCylinder3D)
        case ellipse(REllipse3D)
        case disk(RDisk3D)
        case lineSegment(RLineSegment3D)
        case plane(RPlane3D)
        case torus(RTorus3D)
        case hyperplane(RHyperplane3D)
    }
}

private class Visitor: ElementVisitor {
    typealias ResultType = FoundElement?
    
    // The ID of the geometry that is being searched.
    var id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement {
        return element.accept(self)
    }
    func visit<T>(_ element: T) -> ResultType where T: Element {
        return element.accept(self)
    }

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType {
        if element.id == id {
            return .element(.aabb(element.geometry))
        }
        return nil
    }
    func visit(_ element: CubeElement) -> ResultType {
        if element.id == id {
            return .element(.aabb(element.geometry.bounds))
        }
        return nil
    }
    func visit(_ element: CylinderElement) -> ResultType {
        if element.id == id {
            return .element(.cylinder(element.geometry))
        }
        return nil
    }
    func visit(_ element: DiskElement) -> ResultType {
        if element.id == id {
            return .element(.disk(element.geometry))
        }
        return nil
    }
    func visit(_ element: EllipseElement) -> ResultType {
        if element.id == id {
            return .element(.ellipse(element.geometry))
        }
        return nil
    }
    func visit(_ element: EmptyElement) -> ResultType {
        return nil
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        return nil
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        if element.id == id {
            return .element(.lineSegment(element.geometry))
        }
        return nil
    }
    func visit(_ element: PlaneElement) -> ResultType {
        if element.id == id {
            return .element(.plane(element.geometry))
        }
        return nil
    }
    func visit(_ element: SphereElement) -> ResultType {
        if element.id == id {
            return .element(.sphere(element.geometry))
        }
        return nil
    }
    func visit(_ element: TorusElement) -> ResultType {
        if element.id == id {
            return .element(.torus(element.geometry))
        }
        return nil
    }
    func visit(_ element: HyperplaneElement) -> ResultType {
        if element.id == id {
            return .element(.hyperplane(element.geometry))
        }
        return nil
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        return element.element.accept(self)
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        return element.element.accept(self)
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        for el in element.elements {
            if let result = el.accept(self) {
                return result
            }
        }
        
        return nil
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        return element.t0.accept(self) ?? element.t1.accept(self)
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        return element.t0.accept(self) ?? element.t1.accept(self)
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        for el in element.elements {
            if let result = el.accept(self) {
                return result
            }
        }
        
        return nil
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        return element.t0.accept(self) ?? element.t1.accept(self)
    }

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType {
        return element.element.accept(self)
    }

    // MARK: Transforming

    func visit<T>(_ element: RotateElement<T>) -> ResultType {
        let mat = RMatrix4x4.identity
            .applying3DRotation(
                element.rotation,
                around: element.rotationCenter
            )
        
        return element.element.accept(self)?.transformed(by: mat)
    }
    func visit<T>(_ element: ScaleElement<T>) -> ResultType {
        let mat = Matrix4x4.makeScale(RVector3D(repeating: element.scaling))
        
        return element.element.accept(self)?.transformed(by: mat)
    }
    func visit<T>(_ element: TranslateElement<T>) -> ResultType {
        let mat = Matrix4x4.makeTranslation(element.translation)
        
        return element.element.accept(self)?.transformed(by: mat)
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        return nil
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        return nil
    }
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        return nil
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        return nil
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        return nil
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        return nil
    }
    
    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        if let result = element.t4.accept(self) {
            return result
        }
        return nil
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        if let result = element.t4.accept(self) {
            return result
        }
        return nil
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        if let result = element.t4.accept(self) {
            return result
        }
        if let result = element.t5.accept(self) {
            return result
        }
        return nil
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        if let result = element.t4.accept(self) {
            return result
        }
        if let result = element.t5.accept(self) {
            return result
        }
        return nil
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        if let result = element.t4.accept(self) {
            return result
        }
        if let result = element.t5.accept(self) {
            return result
        }
        if let result = element.t6.accept(self) {
            return result
        }
        return nil
    }
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        if let result = element.t4.accept(self) {
            return result
        }
        if let result = element.t5.accept(self) {
            return result
        }
        if let result = element.t6.accept(self) {
            return result
        }
        return nil
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        if let result = element.t4.accept(self) {
            return result
        }
        if let result = element.t5.accept(self) {
            return result
        }
        if let result = element.t6.accept(self) {
            return result
        }
        if let result = element.t7.accept(self) {
            return result
        }
        return nil
    }
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        
        if let result = element.t0.accept(self) {
            return result
        }
        if let result = element.t1.accept(self) {
            return result
        }
        if let result = element.t2.accept(self) {
            return result
        }
        if let result = element.t3.accept(self) {
            return result
        }
        if let result = element.t4.accept(self) {
            return result
        }
        if let result = element.t5.accept(self) {
            return result
        }
        if let result = element.t6.accept(self) {
            return result
        }
        if let result = element.t7.accept(self) {
            return result
        }
        return nil
    }
}
