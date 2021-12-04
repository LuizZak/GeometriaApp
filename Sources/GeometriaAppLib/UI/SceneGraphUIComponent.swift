import Foundation
import ImagineUI

class SceneGraphUIComponent: RaytracerUIComponent {
    private let treeView = TreeView()
    private var sceneDataSource: SceneDataSource?

    let sidePanel: SidePanel

    weak var delegate: RaytracerUIComponentDelegate?

    init(width: Double) {
        self.sidePanel = SidePanel(pinSide: .left, length: width)
    }

    func setup(container: View) {
        container.addSubview(sidePanel)
        sidePanel.addSubview(treeView)

        treeView.layout.makeConstraints { make in
            make.edges == sidePanel.contentBounds
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
        var root: SceneGraphUINode

        init(root: SceneGraphUINode) {
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

        func titleForItem(at index: TreeView.ItemIndex) -> AttributedText {
            let item: ItemType = itemAt(hierarchyIndex: index.asHierarchyIndex)

            switch item {
            case .node(let node):
                return AttributedText(node.title)
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
            case node(SceneGraphUINode)
            case property(SceneGraphUINode.PropertyEntry)
            case subnodes(SceneGraphUINode)

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

private class SceneGraphUINode {
    var title: String
    var properties: [PropertyEntry] = []
    var subnodes: [SceneGraphUINode] = []

    init(title: String) {
        self.title = title
    }

    func addProperty(name: String, value: String) {
        properties.append(.init(name: name, value: value))
    }

    func addProperty<Value>(name: String, value: Value) {
        properties.append(.init(name: name, value: String(describing: value)))
    }

    func addSubNode(_ node: SceneGraphUINode) {
        assert(node !== self)

        subnodes.append(node)
    }

    func addSubNodes<S: Sequence>(_ nodes: S) where S.Element == SceneGraphUINode {
        for node in nodes {
            addSubNode(node)
        }
    }

    func addingProperty(name: String, value: String) -> SceneGraphUINode {
        properties.append(.init(name: name, value: value))

        return self
    }

    func addingProperty<Value>(name: String, value: Value) -> SceneGraphUINode {
        properties.append(.init(name: name, value: String(describing: value)))

        return self
    }

    func addingSubNode(_ node: SceneGraphUINode) -> SceneGraphUINode {
        assert(node !== self)

        subnodes.append(node)

        return self
    }

    func addingSubNodes<S: Sequence>(_ nodes: S) -> SceneGraphUINode where S.Element == SceneGraphUINode {
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

extension SceneGraphUINode {
    func addingProperty(name: String, value: RVector3D) -> SceneGraphUINode {
        addingProperty(name: name, value: "(\(value.x), \(value.y), \(value.z))")
    }

    func addingProperties<T: Element>(for element: T) -> SceneGraphUINode {
        return self
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphUINode where T.GeometryType == RSphere3D {
        self.addingProperty(name: "Center", value: element.geometry.center)
            .addingProperty(name: "Radius", value: element.geometry.radius)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphUINode where T.GeometryType == RCube3D {
        self.addingProperty(name: "Origin", value: element.geometry.location)
            .addingProperty(name: "Length", value: element.geometry.sideLength)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphUINode where T.GeometryType == RTorus3D {
        self.addingProperty(name: "Major", value: element.geometry.majorRadius)
            .addingProperty(name: "Minor", value: element.geometry.minorRadius)
            .addingProperty(name: "Axis", value: element.geometry.axis)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphUINode where T.GeometryType == RAABB3D {
        self.addingProperty(name: "Minimum", value: element.geometry.minimum)
            .addingProperty(name: "Maximum", value: element.geometry.maximum)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphUINode where T.GeometryType == RPlane3D {
        self.addingProperty(name: "Origin", value: element.geometry.point)
            .addingProperty(name: "Normal", value: element.geometry.normal)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphUINode where T.GeometryType == RDisk3D {
        self.addingProperty(name: "Center", value: element.geometry.center)
            .addingProperty(name: "Radius", value: element.geometry.radius)
            .addingProperty(name: "Normal", value: element.geometry.normal)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphUINode where T.GeometryType == RCylinder3D {
        self.addingProperty(name: "Start", value: element.geometry.start)
            .addingProperty(name: "End", value: element.geometry.end)
            .addingProperty(name: "Radius", value: element.geometry.radius)
    }

    
    func addingProperties<T>(for element: BoundingBoxElement<T>) -> SceneGraphUINode {
        self.addingProperty(name: "Bounds", value: element.boundingBox)
    }

    func addingProperties<T>(for element: BoundingSphereElement<T>) -> SceneGraphUINode {
        self.addingProperty(name: "Bounds", value: element.boundingSphere)
    }

    func addingProperties<T>(for element: RepeatTranslateElement<T>) -> SceneGraphUINode {
        self.addingProperty(name: "Translation", value: element.translation)
            .addingProperty(name: "Count", value: element.count)
    }

    func addingProperties<T>(for element: ScaleElement<T>) -> SceneGraphUINode {
        self.addingProperty(name: "Factor", value: element.scaling)
            .addingProperty(name: "Center", value: element.scalingCenter)
    }

    func addingProperties<T>(for element: TranslateElement<T>) -> SceneGraphUINode {
        self.addingProperty(name: "Translation", value: element.translation)
    }
}

// MARK: - SceneGraphVisitor

private class SceneGraphVisitor: ElementVisitor {
    typealias ResultType = SceneGraphUINode

    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement {
        SceneGraphUINode(title: "\(type(of: element))")
            .addingProperties(for: element)
    }
    func visit<T>(_ element: T) -> ResultType where T: Element {
        SceneGraphUINode(title: "\(type(of: element))")
            .addingProperties(for: element)
    }

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType {
        SceneGraphUINode(title: "AABB")
            .addingProperties(for: element)
    }
    func visit(_ element: CubeElement) -> ResultType {
        SceneGraphUINode(title: "Cube")
            .addingProperties(for: element)
    }
    func visit(_ element: CylinderElement) -> ResultType {
        SceneGraphUINode(title: "Cylinder")
            .addingProperties(for: element)
    }
    func visit(_ element: DiskElement) -> ResultType {
        SceneGraphUINode(title: "Disk")
            .addingProperties(for: element)
    }
    func visit(_ element: EllipseElement) -> ResultType {
        SceneGraphUINode(title: "Ellipse")
            .addingProperties(for: element)
    }
    func visit(_ element: EmptyElement) -> ResultType {
        SceneGraphUINode(title: "Empty element")
            .addingProperties(for: element)
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        SceneGraphUINode(title: "Generic geometry")
            .addingProperties(for: element)
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        SceneGraphUINode(title: "Line segment")
            .addingProperties(for: element)
    }
    func visit(_ element: PlaneElement) -> ResultType {
        SceneGraphUINode(title: "Plane")
            .addingProperties(for: element)
    }
    func visit(_ element: SphereElement) -> ResultType {
        SceneGraphUINode(title: "Sphere")
            .addingProperties(for: element)
    }
    func visit(_ element: TorusElement) -> ResultType {
        SceneGraphUINode(title: "Torus")
            .addingProperties(for: element)
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        SceneGraphUINode(title: "Bounding Box")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        SceneGraphUINode(title: "Bounding Sphere")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        SceneGraphUINode(title: "Bounded typed array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Intersection")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Subtraction")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        SceneGraphUINode(title: "Typed array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Union")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType {
        SceneGraphUINode(title: "Repeat Translating")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Transforming

    func visit<T>(_ element: ScaleElement<T>) -> ResultType {
        SceneGraphUINode(title: "Scale")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T>(_ element: TranslateElement<T>) -> ResultType {
        SceneGraphUINode(title: "Translate")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "2 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "2 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        SceneGraphUINode(title: "3 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        SceneGraphUINode(title: "3 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphUINode(title: "4 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphUINode(title: "4 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphUINode(title: "5 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphUINode(title: "5 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphUINode(title: "6 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphUINode(title: "6 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphUINode(title: "7 Elements Tuple")
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
        SceneGraphUINode(title: "7 Elements Bounded Tuple")
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
        SceneGraphUINode(title: "8 Elements Tuple")
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
        SceneGraphUINode(title: "8 Elements Bounded Tuple")
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
        SceneGraphUINode(title: "Bounding Box")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: BoundingSphereElement<T>) -> ResultType {
        SceneGraphUINode(title: "Bounding Sphere")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Combination

    func visit<T: RaymarchingElement>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        SceneGraphUINode(title: "Bounded typed array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Intersection")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Subtraction")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: TypedArrayElement<T>) -> ResultType {
        SceneGraphUINode(title: "Typed array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: UnionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Union")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T: RaymarchingElement>(_ element: RepeatTranslateElement<T>) -> ResultType {
        SceneGraphUINode(title: "Repeat Translating")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Transforming

    func visit<T: RaymarchingElement>(_ element: ScaleElement<T>) -> ResultType {
        SceneGraphUINode(title: "Scale")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: TranslateElement<T>) -> ResultType {
        SceneGraphUINode(title: "Translate")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleRaymarchingElement2<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "2 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement {
        SceneGraphUINode(title: "2 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    
    func visit<T0, T1, T2>(_ element: TupleRaymarchingElement3<T0, T1, T2>) -> ResultType {
        SceneGraphUINode(title: "3 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement {
        SceneGraphUINode(title: "3 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleRaymarchingElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphUINode(title: "4 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement {
        SceneGraphUINode(title: "4 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleRaymarchingElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphUINode(title: "5 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement {
        SceneGraphUINode(title: "5 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleRaymarchingElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphUINode(title: "6 Elements Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement {
        SceneGraphUINode(title: "6 Elements Bounded Tuple")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphUINode(title: "7 Elements Tuple")
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
        SceneGraphUINode(title: "7 Elements Bounded Tuple")
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
        SceneGraphUINode(title: "8 Elements Tuple")
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
        SceneGraphUINode(title: "8 Elements Bounded Tuple")
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
        SceneGraphUINode(title: "Array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }

    func visit(_ element: BoundedArrayRaymarchingElement) -> ResultType {
        SceneGraphUINode(title: "Bounded array")
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }

    func visit<T>(_ element: AbsoluteRaymarchingElement<T>) -> ResultType {
        SceneGraphUINode(title: "Absolute distance")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    func visit<T0, T1>(_ element: OperationRaymarchingElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Custom operation")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T>(_ element: ModuloRaymarchingElement<T>) -> ResultType {
        SceneGraphUINode(title: "Modulo")
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Smoothing

    func visit<T0, T1>(_ element: SmoothIntersectionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Smooth intersection")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    func visit<T0, T1>(_ element: SmoothUnionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Smooth union")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    func visit<T0, T1>(_ element: SmoothSubtractionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(title: "Smooth subtraction")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
}
