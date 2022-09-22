import Foundation
import ImagineUI
import SwiftBlend2D

private typealias RenderingShape = CameraProjection.RenderingShape

class UIProjectionComponent: RaytracerUIComponent {
    private weak var rendererCoordinator: RendererCoordinator?

    private let renderView: UIDrawingView = UIDrawingView()
    private var geometries: [GeometryToRender] = [] {
        didSet {
            renderView.invalidate()
        }
    }
    
    /// Whether to enable rendering of geometries on screen.
    var showGeometries: Bool = true {
        didSet {
            renderView.invalidate()
        }
    }

    /// The Id of geometry objects to render.
    var geometryIdsToShow: Set<Element.Id> = [] {
        didSet {
            renderView.invalidate()
        }
    }

    weak var delegate: RaytracerUIComponentDelegate?

    func setup(container: View) {
        container.addSubview(renderView)
        renderView.layout.makeConstraints { make in
            make.edges == container
        }
        renderView.renderClosure = { [weak self] (renderer, screenRegion) in
            self?.renderOnScreen(renderer, screenRegion: screenRegion)
        }
    }
    
    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {
        
    }

    func rendererChanged<T>(_ renderer: Raytracer<T>) {
        rendererChanged(anyRenderer: renderer)
        
        let traverser = SceneTraverser(camera: renderer.camera)
        renderer.scene.walk(traverser)
        
        geometries = traverser.geometries
    }

    func rendererChanged<T>(_ renderer: Raymarcher<T>) {
        rendererChanged(anyRenderer: renderer)
        
        let traverser = SceneTraverser(camera: renderer.camera)
        renderer.scene.walk(traverser)
        
        geometries = traverser.geometries
    }

    func rendererChanged<T: RendererType>(anyRenderer: T) {
        renderView.invalidate()
    }
    
    func mouseMoved(event: MouseEventArgs) {
        
    }
    
    func renderOnScreen(_ context: Renderer, screenRegion: ClipRegionType) {
        guard showGeometries else {
            return
        }
        
        for geometry in geometries {
            guard geometryIdsToShow.contains(geometry.id) else { continue }

            renderShape(context, geometry.shape)
        }
    }

    private func doStroke(_ context: Renderer, _ stroker: (Renderer) -> Void) {
        context.setStroke(
            StrokeStyle(
                color: .white,
                width: 3,
                startCap: .round,
                endCap: .round,
                joinStyle: .round
            )
        )

        context.saveState()
        stroker(context)
        context.restoreState()

        context.setStroke(
            StrokeStyle(
                color: .red,
                width: 2,
                startCap: .round,
                endCap: .round,
                joinStyle: .round
            )
        )

        context.saveState()
        stroker(context)
        context.restoreState()
    }

    private func renderShape(_ context: Renderer, _ shape: RenderingShape) {
        context.saveState()
        defer { context.restoreState() }

        switch shape {
        case .ellipse(let ellipse):
            doStroke(context) {
                $0.stroke(ellipse)
            }
            
        case .line(let line):
            doStroke(context) {
                $0.stroke(line)
            }
            
        case .shapes(let shapes):
            for shape in shapes {
                renderShape(context, shape)
            }

        case .transform(let transform, let shape):
            doStroke(context) {
                $0.transform(transform)

                renderShape($0, shape)
            }
        }
    }
}

private enum GeometryToRender {
    case ellipse(id: Element.Id, RenderingShape)
    case aabb(id: Element.Id, RenderingShape)
    case line(id: Element.Id, RenderingShape)
    case disk(id: Element.Id, RenderingShape)

    var id: Element.Id {
        switch self {
        case .ellipse(let id, _),
            .aabb(let id, _),
            .line(let id, _),
            .disk(let id, _):
            
            return id
        }
    }

    var shape: RenderingShape {
        switch self {
        case .ellipse(_, let shape),
            .aabb(_, let shape),
            .line(_, let shape),
            .disk(_, let shape):
            
            return shape
        }
    }
}

private class UIDrawingView: ImagineUI.View {
    var renderClosure: ((_ context: Renderer, _ screenRegion: ClipRegionType) -> Void)?
    
    override func render(in context: Renderer, screenRegion: ClipRegionType) {
        super.render(in: context, screenRegion: screenRegion)
        
        renderClosure?(context, screenRegion)
    }
}

private class SceneTraverser: ElementVisitor {
    typealias ResultType = Void
    
    var geometries: [GeometryToRender] = []
    let camera: Camera
    let projector: CameraProjection
    
    init(camera: Camera) {
        self.camera = camera
        self.projector = CameraProjection(camera: camera)
    }

    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement {
        
    }
    func visit<T>(_ element: T) -> ResultType where T: Element {
        
    }

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType {
        let shape = projector.projectAABB(element.geometry)
        guard !shape.isEmpty else {
            return
        }
        
        geometries.append(
            .aabb(id: element.id, shape)
        )
    }
    func visit(_ element: CubeElement) -> ResultType {
        let shape = projector.projectAABB(element.geometry)
        guard !shape.isEmpty else {
            return
        }
        
        geometries.append(
            .aabb(id: element.id, shape)
        )
    }
    func visit(_ element: CylinderElement) -> ResultType {
        // TODO: Support cylinders
    }
    func visit(_ element: DiskElement) -> ResultType {
        guard let shape = projector.projectDisk(element.geometry) else {
            return
        }
        
        geometries.append(
            .disk(id: element.id, shape)
        )
    }
    func visit(_ element: EllipseElement) -> ResultType {
        // TODO: Support ellipses
    }
    func visit(_ element: EmptyElement) -> ResultType {
        
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        guard let shape = projector.projectLine(element.geometry) else {
            return
        }
        
        geometries.append(
            .line(id: element.id, shape)
        )
    }
    func visit(_ element: PlaneElement) -> ResultType {
        
    }
    func visit(_ element: SphereElement) -> ResultType {
        guard let shape = projector.projectSphere(element.geometry) else {
            return
        }
        
        geometries.append(
            .ellipse(id: element.id, shape)
        )
    }
    func visit(_ element: TorusElement) -> ResultType {
        
    }
    func visit(_ element: HyperplaneElement) -> ResultType {
        
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        element.element.accept(self)
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        element.element.accept(self)
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        element.elements.forEach {
            $0.accept(self)
        }
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        element.elements.forEach {
            $0.accept(self)
        }
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
    }

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType {
        // TODO: Support transformations properly
        element.element.accept(self)
    }

    // MARK: Transforming

    func visit<T>(_ element: ScaleElement<T>) -> ResultType {
        // TODO: Support transformations properly
        element.element.accept(self)
    }
    func visit<T>(_ element: TranslateElement<T>) -> ResultType {
        // TODO: Support transformations properly
        element.element.accept(self)
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
    }
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
        element.t4.accept(self)
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
        element.t4.accept(self)
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
        element.t4.accept(self)
        element.t5.accept(self)
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
        element.t4.accept(self)
        element.t5.accept(self)
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
        element.t4.accept(self)
        element.t5.accept(self)
        element.t6.accept(self)
    }
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
        element.t4.accept(self)
        element.t5.accept(self)
        element.t6.accept(self)
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
        element.t4.accept(self)
        element.t5.accept(self)
        element.t6.accept(self)
        element.t7.accept(self)
    }
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        element.t0.accept(self)
        element.t1.accept(self)
        element.t2.accept(self)
        element.t3.accept(self)
        element.t4.accept(self)
        element.t5.accept(self)
        element.t6.accept(self)
        element.t7.accept(self)
    }
}
