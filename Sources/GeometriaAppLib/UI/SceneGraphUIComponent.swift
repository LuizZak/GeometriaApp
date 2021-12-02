import Foundation
import ImagineUI

class SceneGraphUIComponent: RaytracerUIComponent {
    private var width: Double

    private let scrollView = ScrollView(scrollBarsMode: .vertical)
    private let treeView = TreeView()
    private var sceneDataSource: SceneDataSource?

    weak var delegate: RaytracerUIComponentDelegate?

    init(width: Double) {
        self.width = width
    }

    func setup(container: View) {
        container.addSubview(treeView)

        treeView.layout.makeConstraints { make in
            make.left == container.layout.left
            make.top == container.layout.top
            make.bottom == container.layout.bottom
            make.width == self.width
        }
    }

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {

    }

    func rendererChanged(_ renderer: RendererType) {
        updateGraph(scene: renderer.currentScene())
    }

    func mouseMoved(event: MouseEventArgs) {

    }

    private func updateGraph(scene: SceneType) {
        let visitor = SceneGraphVisitor()
        let graph = scene.walk(visitor)

        sceneDataSource = SceneDataSource(root: graph)

        treeView.dataSource = sceneDataSource
        treeView.reloadData()
    }

    private class SceneDataSource: TreeViewDataSource {
        var root: SceneGraphNode

        init(root: SceneGraphNode) {
            self.root = root
        }

        func nodeAt(hierarchyIndex: TreeView.HierarchyIndex) -> SceneGraphNode {
            var node = root

            for index in hierarchyIndex.indices {
                node = node.subnodes[index]
            }

            return node
        }

        func hasSubItems(at index: TreeView.ItemIndex) -> Bool {
            !nodeAt(hierarchyIndex: index.asHierarchyIndex).subnodes.isEmpty
        }

        func numberOfItems(at hierarchyIndex: TreeView.HierarchyIndex) -> Int {
            nodeAt(hierarchyIndex: hierarchyIndex).subnodes.count
        }

        func titleForItem(at index: TreeView.ItemIndex) -> String {
            nodeAt(hierarchyIndex: index.asHierarchyIndex).title
        }

        func iconForItem(at index: TreeView.ItemIndex) -> Image? {
            return nil
        }
    }
}

private class SceneGraphNode {
    var title: String
    var subnodes: [SceneGraphNode] = []

    init(title: String) {
        self.title = title
    }

    func addSubNode(_ node: SceneGraphNode) {
        assert(node !== self)

        subnodes.append(node)
    }

    func addSubNodes<S: Sequence>(_ nodes: S) where S.Element == SceneGraphNode {
        for node in nodes {
            addSubNode(node)
        }
    }
}

private class SceneGraphVisitor: ElementVisitor {
    typealias ResultType = SceneGraphNode

    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit<T>(_ element: T) -> ResultType where T: Element {
        SceneGraphNode(title: "\(type(of: element))")
    }

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType {
        SceneGraphNode(title: "AABB (\(element.geometry))")
    }
    func visit(_ element: CubeElement) -> ResultType {
        SceneGraphNode(title: "Cube (\(element.geometry))")
    }
    func visit(_ element: CylinderElement) -> ResultType {
        SceneGraphNode(title: "Cylinder (\(element.geometry))")
    }
    func visit(_ element: DiskElement) -> ResultType {
        SceneGraphNode(title: "Disk (\(element.geometry))")
    }
    func visit(_ element: EllipseElement) -> ResultType {
        SceneGraphNode(title: "Ellipse (\(element.geometry))")
    }
    func visit(_ element: EmptyElement) -> ResultType {
        SceneGraphNode(title: "Empty element")
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        SceneGraphNode(title: "Generic geometry (\(element.geometry))")
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        SceneGraphNode(title: "Line segment (\(element.geometry))")
    }
    func visit(_ element: PlaneElement) -> ResultType {
        SceneGraphNode(title: "Plane (\(element.geometry))")
    }
    func visit(_ element: SphereElement) -> ResultType {
        SceneGraphNode(title: "Sphere (\(element.geometry))")
    }
    func visit(_ element: TorusElement) -> ResultType {
        SceneGraphNode(title: "Torus (\(element.geometry))")
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Bounding Box (\(element.boundingBox))")

        node.addSubNode(element.element.accept(self))

        return node
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Bounding Sphere (\(element.boundingSphere))")

        node.addSubNode(element.element.accept(self))

        return node
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Bounded typed array (\(element.elements.count) element(s), typed \(T.self))")

        node.addSubNodes(element.elements.map { $0.accept(self) })

        return node
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "Intersection")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "Subtraction")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Typed array (\(element.elements.count) element(s), typed \(T.self))")

        node.addSubNodes(element.elements.map { $0.accept(self) })

        return node
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "Union")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Repeat Translating (\(element.translation), \(element.count) times)")

        node.addSubNode(element.element.accept(self))

        return node
    }

    // MARK: Transforming

    func visit<T>(_ element: ScaleElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Scale (\(element.scaling)x, @\(element.scalingCenter))")

        node.addSubNode(element.element.accept(self))

        return node
    }
    func visit<T>(_ element: TranslateElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Translate (\(element.translation))")

        node.addSubNode(element.element.accept(self))

        return node
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "2 Elements Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "2 Elements Bounded Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        let node = SceneGraphNode(title: "3 Elements Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))

        return node
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        let node = SceneGraphNode(title: "3 Elements Bounded Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))

        return node
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        let node = SceneGraphNode(title: "4 Elements Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))

        return node
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        let node = SceneGraphNode(title: "4 Elements Bounded Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))

        return node
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        let node = SceneGraphNode(title: "5 Elements Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))

        return node
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        let node = SceneGraphNode(title: "5 Elements Bounded Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))

        return node
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        let node = SceneGraphNode(title: "6 Elements Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))
        node.addSubNode(element.t5.accept(self))

        return node
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        let node = SceneGraphNode(title: "6 Elements Bounded Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))
        node.addSubNode(element.t5.accept(self))

        return node
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        let node = SceneGraphNode(title: "7 Elements Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))
        node.addSubNode(element.t5.accept(self))
        node.addSubNode(element.t6.accept(self))

        return node
    }
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        let node = SceneGraphNode(title: "7 Elements Bounded Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))
        node.addSubNode(element.t5.accept(self))
        node.addSubNode(element.t6.accept(self))

        return node
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        let node = SceneGraphNode(title: "8 Elements Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))
        node.addSubNode(element.t5.accept(self))
        node.addSubNode(element.t6.accept(self))
        node.addSubNode(element.t7.accept(self))

        return node
    }
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        let node = SceneGraphNode(title: "8 Elements Bounded Tuple")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))
        node.addSubNode(element.t5.accept(self))
        node.addSubNode(element.t6.accept(self))
        node.addSubNode(element.t7.accept(self))

        return node
    }
}

extension SceneGraphVisitor: RaymarchingElementVisitor {
    // MARK: Combination
    func visit(_ element: ArrayRaymarchingElement) -> ResultType {
        let node = SceneGraphNode(title: "Array (\(element.elements.count) element(s))")

        node.addSubNodes(element.elements.map { $0.accept(self) })

        return node
    }

    func visit(_ element: BoundedArrayRaymarchingElement) -> ResultType {
        let node = SceneGraphNode(title: "Bounded array (\(element.elements.count) element(s))")

        node.addSubNodes(element.elements.map { $0.accept(self) })

        return node
    }

    func visit<T>(_ element: AbsoluteRaymarchingElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Absolute distance")

        node.addSubNode(element.element.accept(self))

        return node
    }

    func visit<T0, T1>(_ element: OperationRaymarchingElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "Custom operation")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }

    // MARK: Repeating

    func visit<T>(_ element: ModuloRaymarchingElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "Modulo (phase: \(element.phase))")

        node.addSubNode(element.element.accept(self))

        return node
    }

    // MARK: Smoothing

    func visit<T0, T1>(_ element: SmoothIntersectionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "Smooth intersection")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }

    func visit<T0, T1>(_ element: SmoothUnionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "Smooth union")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }

    func visit<T0, T1>(_ element: SmoothSubtractionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "Smooth subtraction")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
}
