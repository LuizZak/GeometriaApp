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
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: CubeElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: CylinderElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: DiskElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: EllipseElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: EmptyElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: PlaneElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: SphereElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }
    func visit(_ element: TorusElement) -> ResultType {
        SceneGraphNode(title: "\(type(of: element))")
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.element.accept(self))

        return node
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.element.accept(self))

        return node
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNodes(element.elements.map { $0.accept(self) })

        return node
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNodes(element.elements.map { $0.accept(self) })

        return node
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.element.accept(self))

        return node
    }

    // MARK: Transforming

    func visit<T>(_ element: ScaleElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.element.accept(self))

        return node
    }
    func visit<T>(_ element: TranslateElement<T>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.element.accept(self))

        return node
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))

        return node
    }
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))

        return node
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))

        return node
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))

        return node
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))

        return node
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))

        return node
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))

        return node
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))
        node.addSubNode(element.t5.accept(self))

        return node
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

        node.addSubNode(element.t0.accept(self))
        node.addSubNode(element.t1.accept(self))
        node.addSubNode(element.t2.accept(self))
        node.addSubNode(element.t3.accept(self))
        node.addSubNode(element.t4.accept(self))
        node.addSubNode(element.t5.accept(self))

        return node
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        let node = SceneGraphNode(title: "\(type(of: element))")

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
        let node = SceneGraphNode(title: "\(type(of: element))")

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
        let node = SceneGraphNode(title: "\(type(of: element))")

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
        let node = SceneGraphNode(title: "\(type(of: element))")

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
