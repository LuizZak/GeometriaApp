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

    func rendererChanged<T: RendererType>(anyRenderer: T) {
        let graph = anyRenderer.currentScene().walk(SceneGraphVisitor())

        updateDataSource(SceneDataSource(root: graph))
    }

    func rendererChanged<T>(_ renderer: Raymarcher<T>) {
        let graph = renderer.scene.walk(SceneGraphVisitor())

        updateDataSource(SceneDataSource(root: graph))
    }

    func mouseMoved(event: MouseEventArgs) {

    }

    private func updateDataSource(_ dataSource: SceneDataSource?) {
        sceneDataSource = dataSource

        treeView.dataSource = dataSource
        treeView.reloadData()
    }

    private class SceneDataSource: TreeViewDataSource {
        var root: SceneGraphNode

        init(root: SceneGraphNode) {
            self.root = root
        }

        func itemAt(hierarchyIndex: TreeView.HierarchyIndex) -> ItemType {
            var item = ItemType.node(root)

            for index in hierarchyIndex.indices {
                item = item.indexInto(index)
            }

            return item
        }

        func hasSubItems(at index: TreeView.ItemIndex) -> Bool {
            itemAt(hierarchyIndex: index.asHierarchyIndex).hasElements()
        }

        func numberOfItems(at hierarchyIndex: TreeView.HierarchyIndex) -> Int {
            itemAt(hierarchyIndex: hierarchyIndex).elementCount()
        }

        func titleForItem(at index: TreeView.ItemIndex) -> String {
            let item: ItemType = itemAt(hierarchyIndex: index.asHierarchyIndex)

            switch item {
            case .node(let node):
                return node.title
            case .property(let property):
                return "\(property.name): \(property.value)"
            case .subnodes:
                return "Children"
            }
        }

        func iconForItem(at index: TreeView.ItemIndex) -> Image? {
            return nil
        }

        enum ItemType {
            case node(SceneGraphNode)
            case property(SceneGraphNode.PropertyEntry)
            case subnodes(SceneGraphNode)

            func hasElements() -> Bool {
                elementCount() > 0
            }

            func elementCount() -> Int {
                switch self {
                case .node(let node):
                    if node.properties.isEmpty {
                        return node.subnodes.count
                    }
                    if node.subnodes.isEmpty {
                        return node.properties.count
                    }

                    return node.properties.count + 1
                
                case .property:
                    return 0
                
                case .subnodes(let node):
                    return node.subnodes.count
                }
            }

            func indexInto(_ index: Int) -> ItemType {
                switch self {
                case .node(let node):
                    if node.properties.isEmpty {
                        return .node(node.subnodes[index])
                    }

                    if index < node.properties.count {
                        return .property(node.properties[index])
                    }

                    return .subnodes(node)
                
                case .property:
                    fatalError("Cannot index into a property")
                
                case .subnodes(let node):
                    return .node(node.subnodes[index])
                }
            }
        }
    }
}

private class SceneGraphNode {
    var title: String
    var properties: [PropertyEntry] = []
    var subnodes: [SceneGraphNode] = []

    init(title: String) {
        self.title = title
    }

    func addProperty(name: String, value: String) {
        properties.append(.init(name: name, value: value))
    }

    func addProperty<Value>(name: String, value: Value) {
        properties.append(.init(name: name, value: String(describing: value)))
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

    func addingProperty(name: String, value: String) -> SceneGraphNode {
        properties.append(.init(name: name, value: value))

        return self
    }

    func addingProperty<Value>(name: String, value: Value) -> SceneGraphNode {
        properties.append(.init(name: name, value: String(describing: value)))

        return self
    }

    func addingSubNode(_ node: SceneGraphNode) -> SceneGraphNode {
        assert(node !== self)

        subnodes.append(node)

        return self
    }

    func addingSubNodes<S: Sequence>(_ nodes: S) -> SceneGraphNode where S.Element == SceneGraphNode {
        for node in nodes {
            addSubNode(node)
        }

        return self
    }

    struct PropertyEntry {
        var name: String
        var value: String
    }
}

// MARK: - Property derivation

extension SceneGraphNode {
    func addingProperty(name: String, value: RVector3D) -> SceneGraphNode {
        addingProperty(name: name, value: "(\(value.x), \(value.y), \(value.z))")
    }

    func addingProperties<T: Element>(for element: T) -> SceneGraphNode {
        return self
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphNode where T.GeometryType == RSphere3D {
        self.addingProperty(name: "Center", value: element.geometry.center)
            .addingProperty(name: "Radius", value: element.geometry.radius)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphNode where T.GeometryType == RCube3D {
        self.addingProperty(name: "Origin", value: element.geometry.location)
            .addingProperty(name: "Length", value: element.geometry.sideLength)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphNode where T.GeometryType == RTorus3D {
        self.addingProperty(name: "Major", value: element.geometry.majorRadius)
            .addingProperty(name: "Minor", value: element.geometry.minorRadius)
            .addingProperty(name: "Axis", value: element.geometry.axis)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphNode where T.GeometryType == RAABB3D {
        self.addingProperty(name: "Minimum", value: element.geometry.minimum)
            .addingProperty(name: "Maximum", value: element.geometry.maximum)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphNode where T.GeometryType == RPlane3D {
        self.addingProperty(name: "Origin", value: element.geometry.point)
            .addingProperty(name: "Normal", value: element.geometry.normal)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphNode where T.GeometryType == RDisk3D {
        self.addingProperty(name: "Center", value: element.geometry.center)
            .addingProperty(name: "Radius", value: element.geometry.radius)
            .addingProperty(name: "Normal", value: element.geometry.normal)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphNode where T.GeometryType == RCylinder3D {
        self.addingProperty(name: "Start", value: element.geometry.start)
            .addingProperty(name: "End", value: element.geometry.end)
            .addingProperty(name: "Radius", value: element.geometry.radius)
    }

    
    func addingProperties<T>(for element: BoundingBoxElement<T>) -> SceneGraphNode {
        self.addingProperty(name: "Bounds", value: element.boundingBox)
    }

    func addingProperties<T>(for element: BoundingSphereElement<T>) -> SceneGraphNode {
        self.addingProperty(name: "Bounds", value: element.boundingSphere)
    }

    func addingProperties<T>(for element: RepeatTranslateElement<T>) -> SceneGraphNode {
        self.addingProperty(name: "Translation", value: element.translation)
            .addingProperty(name: "Count", value: element.count)
    }

    func addingProperties<T>(for element: ScaleElement<T>) -> SceneGraphNode {
        self.addingProperty(name: "Factor", value: element.scaling)
            .addingProperty(name: "Center", value: element.scalingCenter)
    }

    func addingProperties<T>(for element: TranslateElement<T>) -> SceneGraphNode {
        self.addingProperty(name: "Translation", value: element.translation)
    }
}

// MARK: - SceneGraphVisitor

private class SceneGraphVisitor: ElementVisitor {
    typealias ResultType = SceneGraphNode

    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement {
        SceneGraphNode(title: "\(type(of: element))")
            .addingProperties(for: element)
    }
    func visit<T>(_ element: T) -> ResultType where T: Element {
        SceneGraphNode(title: "\(type(of: element))")
            .addingProperties(for: element)
    }

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType {
        SceneGraphNode(title: "AABB")
            .addingProperties(for: element)
    }
    func visit(_ element: CubeElement) -> ResultType {
        SceneGraphNode(title: "Cube")
            .addingProperties(for: element)
    }
    func visit(_ element: CylinderElement) -> ResultType {
        SceneGraphNode(title: "Cylinder")
            .addingProperties(for: element)
    }
    func visit(_ element: DiskElement) -> ResultType {
        SceneGraphNode(title: "Disk")
            .addingProperties(for: element)
    }
    func visit(_ element: EllipseElement) -> ResultType {
        SceneGraphNode(title: "Ellipse")
            .addingProperties(for: element)
    }
    func visit(_ element: EmptyElement) -> ResultType {
        SceneGraphNode(title: "Empty element")
            .addingProperties(for: element)
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        SceneGraphNode(title: "Generic geometry")
            .addingProperties(for: element)
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        SceneGraphNode(title: "Line segment")
            .addingProperties(for: element)
    }
    func visit(_ element: PlaneElement) -> ResultType {
        SceneGraphNode(title: "Plane")
            .addingProperties(for: element)
    }
    func visit(_ element: SphereElement) -> ResultType {
        SceneGraphNode(title: "Sphere")
            .addingProperties(for: element)
    }
    func visit(_ element: TorusElement) -> ResultType {
        SceneGraphNode(title: "Torus")
            .addingProperties(for: element)
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        SceneGraphNode(title: "Bounding Box")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        SceneGraphNode(title: "Bounding Sphere")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        SceneGraphNode(title: "Bounded typed array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Intersection")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Subtraction")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        SceneGraphNode(title: "Typed array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Union")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType {
        SceneGraphNode(title: "Repeat Translating")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Transforming

    func visit<T>(_ element: ScaleElement<T>) -> ResultType {
        SceneGraphNode(title: "Scale")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T>(_ element: TranslateElement<T>) -> ResultType {
        SceneGraphNode(title: "Translate")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType {
        SceneGraphNode(title: "2 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        SceneGraphNode(title: "2 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        SceneGraphNode(title: "3 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        SceneGraphNode(title: "3 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphNode(title: "4 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphNode(title: "4 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphNode(title: "5 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphNode(title: "5 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphNode(title: "6 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphNode(title: "6 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphNode(title: "7 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
            .addingSubNode(element.t6.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphNode(title: "7 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
            .addingSubNode(element.t6.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        SceneGraphNode(title: "8 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
            .addingSubNode(element.t6.accept(self))
            .addingSubNode(element.t7.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        SceneGraphNode(title: "8 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
            .addingSubNode(element.t6.accept(self))
            .addingSubNode(element.t7.accept(self))
    }
}

extension SceneGraphVisitor: RaymarchingElementVisitor {
    // MARK: Bounding

    func visit<T: RaymarchingElement>(_ element: BoundingBoxElement<T>) -> ResultType {
        SceneGraphNode(title: "Bounding Box")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: BoundingSphereElement<T>) -> ResultType {
        SceneGraphNode(title: "Bounding Sphere")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Combination

    func visit<T: RaymarchingElement>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        SceneGraphNode(title: "Bounded typed array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Intersection")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Subtraction")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: TypedArrayElement<T>) -> ResultType {
        SceneGraphNode(title: "Typed array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: UnionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Union")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T: RaymarchingElement>(_ element: RepeatTranslateElement<T>) -> ResultType {
        SceneGraphNode(title: "Repeat Translating")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Transforming

    func visit<T: RaymarchingElement>(_ element: ScaleElement<T>) -> ResultType {
        SceneGraphNode(title: "Scale")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: TranslateElement<T>) -> ResultType {
        SceneGraphNode(title: "Translate")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleRaymarchingElement2<T0, T1>) -> ResultType {
        SceneGraphNode(title: "2 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement {
        SceneGraphNode(title: "2 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    
    func visit<T0, T1, T2>(_ element: TupleRaymarchingElement3<T0, T1, T2>) -> ResultType {
        SceneGraphNode(title: "3 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement {
        SceneGraphNode(title: "3 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleRaymarchingElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphNode(title: "4 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement {
        SceneGraphNode(title: "4 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleRaymarchingElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphNode(title: "5 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement {
        SceneGraphNode(title: "5 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleRaymarchingElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphNode(title: "6 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement {
        SceneGraphNode(title: "6 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphNode(title: "7 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
            .addingSubNode(element.t6.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T6: RaymarchingElement {
        SceneGraphNode(title: "7 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
            .addingSubNode(element.t6.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleRaymarchingElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        SceneGraphNode(title: "8 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
            .addingSubNode(element.t6.accept(self))
            .addingSubNode(element.t7.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T7: RaymarchingElement {
        SceneGraphNode(title: "8 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
            .addingSubNode(element.t6.accept(self))
            .addingSubNode(element.t7.accept(self))
    }

    // MARK: Combination
    func visit(_ element: ArrayRaymarchingElement) -> ResultType {
        SceneGraphNode(title: "Array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }

    func visit(_ element: BoundedArrayRaymarchingElement) -> ResultType {
        SceneGraphNode(title: "Bounded array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }

    func visit<T>(_ element: AbsoluteRaymarchingElement<T>) -> ResultType {
        SceneGraphNode(title: "Absolute distance")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    func visit<T0, T1>(_ element: OperationRaymarchingElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Custom operation")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T>(_ element: ModuloRaymarchingElement<T>) -> ResultType {
        SceneGraphNode(title: "Modulo")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Smoothing

    func visit<T0, T1>(_ element: SmoothIntersectionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Smooth intersection")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    func visit<T0, T1>(_ element: SmoothUnionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Smooth union")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    func visit<T0, T1>(_ element: SmoothSubtractionElement<T0, T1>) -> ResultType {
        SceneGraphNode(title: "Smooth subtraction")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
}
