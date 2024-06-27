#if canImport(Geometria)
import Geometria
#endif
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
    }

    func rendererChanged<T>(_ renderer: Raymarcher<T>) {
        rendererChanged(anyRenderer: renderer)
    }

    func rendererChanged<T: RendererType>(anyRenderer: T) {
        let traverser = SceneTraverser(camera: anyRenderer.camera)
        geometries = anyRenderer.currentScene().walk(traverser)

        renderView.invalidate()
    }

    func mouseMoved(event: MouseEventArgs) {

    }

    func renderOnScreen(_ renderer: Renderer, screenRegion: ClipRegionType) {
        guard showGeometries else {
            return
        }

        for geometry in geometries {
            guard geometryIdsToShow.contains(geometry.id) else { continue }

            switch geometry {
            case .subtract(_, let base, let subtracting):
                renderShape(renderer, base)
                renderShape(renderer, subtracting, .structural)

            default:
                let context: RenderContext

                if geometry.isStrictlyGeometry {
                    context = .primitive
                } else {
                    context = .structural
                }

                renderShapes(renderer, geometry.shapes, context)
            }
        }
    }

    private func doStroke(
        _ renderer: Renderer,
        _ context: RenderContext,
        _ stroker: (Renderer) -> Void
    ) {
        renderer.setStroke(
            StrokeStyle(
                color: .white,
                width: 3,
                startCap: .round,
                endCap: .round,
                joinStyle: .round
            )
        )

        renderer.withTemporaryState {
            stroker(renderer)
        }

        renderer.setStroke(
            StrokeStyle(
                color: context.penColor,
                width: 2,
                startCap: .round,
                endCap: .round,
                joinStyle: .round
            )
        )

        renderer.withTemporaryState {
            stroker(renderer)
        }
    }

    private func renderShapes(
        _ renderer: Renderer,
        _ shapes: [RenderingShape],
        _ context: RenderContext = .primitive
    ) {

        for shape in shapes {
            renderShape(renderer, shape, context)
        }
    }

    private func renderShape(
        _ renderer: Renderer,
        _ shape: RenderingShape,
        _ context: RenderContext = .primitive
    ) {

        renderer.saveState()
        defer { renderer.restoreState() }

        switch shape {
        case .ellipse(let ellipse):
            doStroke(renderer, context) { renderer in
                renderer.stroke(ellipse)
            }

        case .line(let line):
            doStroke(renderer, context) { renderer in
                renderer.stroke(line)
            }

        case .shapes(let shapes):
            for shape in shapes {
                renderShape(renderer, shape, context)
            }

        case .transform(let transform, let shape):
            renderer.withTemporaryState {
                renderer.transform(transform)
                renderShape(renderer, shape, context)
            }
        }
    }

    private struct RenderContext {
        static let primitive: RenderContext = .init(
            penColor: IconLibrary.geometryPrimitiveColor
        )
        static let structural: RenderContext = .init(
            penColor: IconLibrary.structuralElementColor
        )

        var penColor: Color
    }
}

private enum GeometryToRender {
    case ellipse(id: Element.Id, RenderingShape)
    case aabb(id: Element.Id, RenderingShape)
    case line(id: Element.Id, RenderingShape)
    case disk(id: Element.Id, RenderingShape)
    case cylinder(id: Element.Id, RenderingShape)
    case bounding(id: Element.Id, RenderingShape)
    case subtract(id: Element.Id, base: RenderingShape, subtracting: RenderingShape)
    case union(id: Element.Id, shapes: [RenderingShape])

    var id: Element.Id {
        switch self {
        case .ellipse(let id, _),
            .aabb(let id, _),
            .line(let id, _),
            .disk(let id, _),
            .cylinder(let id, _),
            .bounding(let id, _),
            .subtract(let id, _, _),
            .union(let id, _):

            return id
        }
    }

    var shapes: [RenderingShape] {
        switch self {
        case .ellipse(_, let shape),
            .aabb(_, let shape),
            .line(_, let shape),
            .disk(_, let shape),
            .bounding(_, let shape),
            .cylinder(_, let shape):

            return [shape]

        case .subtract(_, let shape1, let shape2):
            return [shape1, shape2]

        case .union(_, let shapes):
            return shapes
        }
    }

    /// Returns `true` if this element represents only shapes attached to visible
    /// geometry in the scene.
    var isStrictlyGeometry: Bool {
        switch self {
        case .ellipse,
            .aabb,
            .line,
            .disk,
            .cylinder:
            return true

        case .bounding,
            .subtract,
            .union:
            return false
        }
    }

    /// Returns `true` if this element represents only shapes attached to invisible
    /// structural geometry in the scene.
    var isStrictlyStructural: Bool {
        switch self {
        case .ellipse,
            .aabb,
            .line,
            .disk,
            .cylinder,
            .subtract:
            return false

        case .bounding,
            .union:
            return true
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
    typealias ResultType = [GeometryToRender]

    let camera: Camera
    let projector: CameraProjection

    init(camera: Camera) {
        self.camera = camera
        self.projector = CameraProjection(camera: camera)
    }

    // MARK: General

    func projectAABB<R: RectangleType>(_ aabb: R) -> RenderingShape? where R.Vector == RVector3D {
        let shape = projector.projectAABB(aabb)
        guard !shape.isEmpty else {
            return nil
        }

        return shape
    }

    func projectSphere(_ sphere: RSphere3D) -> RenderingShape? {
        projector.projectSphere(sphere)
    }

    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement {
        []
    }
    func visit<T>(_ element: T) -> ResultType where T: Element {
        []
    }

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType {
        guard let shape = projectAABB(element.geometry) else {
            return []
        }

        return [
            .aabb(id: element.id, shape)
        ]
    }
    func visit(_ element: CubeElement) -> ResultType {
        guard let shape = projectAABB(element.geometry) else {
            return []
        }

        return [
            .aabb(id: element.id, shape)
        ]
    }
    func visit(_ element: CylinderElement) -> ResultType {
        guard let shape = projector.projectCylinder(element.geometry) else {
            return []
        }

        return [
            .cylinder(id: element.id, shape)
        ]
    }
    func visit(_ element: DiskElement) -> ResultType {
        guard let shape = projector.projectDisk(element.geometry) else {
            return []
        }

        return [
            .disk(id: element.id, shape)
        ]
    }
    func visit(_ element: EllipseElement) -> ResultType {
        // TODO: Support ellipses
        return []
    }
    func visit(_ element: EmptyElement) -> ResultType {
        return []
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        return []
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        guard let shape = projector.projectLine(element.geometry) else {
            return []
        }

        return [
            .line(id: element.id, shape)
        ]
    }
    func visit(_ element: PlaneElement) -> ResultType {
        return []
    }
    func visit(_ element: SphereElement) -> ResultType {
        guard let shape = projectSphere(element.geometry) else {
            return []
        }

        return [
            .ellipse(id: element.id, shape)
        ]
    }
    func visit(_ element: TorusElement) -> ResultType {
        return []
    }
    func visit(_ element: HyperplaneElement) -> ResultType {
        return []
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        let el = element.element.accept(self)

        if let shape = projectAABB(element.boundingBox) {
            let result = GeometryToRender.bounding(id: element.id, shape)
            return [result] + el
        }

        return el
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        let el = element.element.accept(self)

        if let shape = projectSphere(element.boundingSphere) {
            let result = GeometryToRender.bounding(id: element.id, shape)
            return [result] + el
        }

        return el
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        element.elements.flatMap {
            $0.accept(self)
        }
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        let t0 = element.t0.accept(self)
        let t1 = element.t1.accept(self)

        let subtract = GeometryToRender.subtract(
            id: element.id,
            base: .shapes(t0.flatMap(\.shapes)),
            subtracting: .shapes(t1.flatMap(\.shapes))
        )

        return [subtract] + t0 + t1
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        element.elements.flatMap {
            $0.accept(self)
        }
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        let t0 = element.t0.accept(self)
        let t1 = element.t1.accept(self)

        let shape = GeometryToRender.union(
            id: element.id,
            shapes: (t0 + t1).flatMap(\.shapes)
        )

        return [shape] + t0 + t1
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
    func visit<T>(_ element: RotateElement<T>) -> ResultType {
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
            + element.t1.accept(self)
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
    }

    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
    }

    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
            + element.t4.accept(self)
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
            + element.t4.accept(self)
    }

    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
            + element.t4.accept(self)
            + element.t5.accept(self)
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
            + element.t4.accept(self)
            + element.t5.accept(self)
    }

    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
            + element.t4.accept(self)
            + element.t5.accept(self)
            + element.t6.accept(self)
    }
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
            + element.t4.accept(self)
            + element.t5.accept(self)
            + element.t6.accept(self)
    }

    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
            + element.t4.accept(self)
            + element.t5.accept(self)
            + element.t6.accept(self)
            + element.t7.accept(self)
    }
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        element.t0.accept(self)
            + element.t1.accept(self)
            + element.t2.accept(self)
            + element.t3.accept(self)
            + element.t4.accept(self)
            + element.t5.accept(self)
            + element.t6.accept(self)
            + element.t7.accept(self)
    }
}
