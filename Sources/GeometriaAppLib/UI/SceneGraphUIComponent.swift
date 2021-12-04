import Foundation
import ImagineUI
import Blend2DRenderer

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

            for index in hierarchyIndex.indices.dropFirst() {
                item = item.indexInto(index)
            }

            return item
        }

        func hasSubItems(at index: TreeView.ItemIndex) -> Bool {
            itemAt(hierarchyIndex: index.asHierarchyIndex).hasElements()
        }

        func numberOfItems(at hierarchyIndex: TreeView.HierarchyIndex) -> Int {
            if hierarchyIndex.isRoot {
                return 1
            }

            return itemAt(hierarchyIndex: hierarchyIndex).elementCount()
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
            let item: ItemType = itemAt(hierarchyIndex: index.asHierarchyIndex)

            return item.icon()
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
                    var count = 1 // ID property
                    count += node.properties.count
                    count += node.subnodes.count

                    return count
                
                case .property:
                    return 0
                
                case .subnodes(let node):
                    return node.subnodes.count
                }
            }

            func indexInto(_ index: Int) -> ItemType {
                switch self {
                case .node(let node):
                    var index = index

                    if index == 0 {
                        return .property(.init(name: "Id", value: "\(node.element.id)"))
                    }
                    index -= 1

                    if index < node.properties.count {
                        return .property(node.properties[index])
                    }
                    index -= node.properties.count
                    
                    return .node(node.subnodes[index])
                
                case .property:
                    fatalError("Cannot index into a property")
                
                case .subnodes(let node):
                    return .node(node.subnodes[index])
                }
            }

            func icon() -> Image? {
                switch self {
                case .node(let node):
                    return node.icon

                case .property:
                    return nil

                case .subnodes:
                    return nil
                }
            }
        }
    }
}

private final class SceneGraphUINode {
    var element: Element
    var title: String
    var icon: Image?
    var properties: [PropertyEntry] = []
    var subnodes: [SceneGraphUINode] = []

    init(element: Element, title: String) {
        self.element = element
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

    func addingIcon(_ icon: Image?) -> SceneGraphUINode {
        self.icon = icon

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

// MARK: - Icon derivation

extension SceneGraphUINode {
    func addingIcon<T: Element>(for element: T) -> SceneGraphUINode {
        return self
    }

    func addingIcon(for element: AABBElement) -> SceneGraphUINode {
        self.addingIcon(IconLibrary.aabbIcon)
    }

    func addingIcon(for element: SphereElement) -> SceneGraphUINode {
        self.addingIcon(IconLibrary.sphereIcon)
    }

    func addingIcon(for element: CylinderElement) -> SceneGraphUINode {
        self.addingIcon(IconLibrary.cylinderIcon)
    }

    func addingIcon(for element: DiskElement) -> SceneGraphUINode {
        self.addingIcon(IconLibrary.diskIcon)
    }

    func addingIcon<T>(for element: RepeatTranslateElement<T>) -> SceneGraphUINode {
        self.addingIcon(IconLibrary.repeatTranslateIcon)
    }

    func addingIcon<T>(for element: BoundingBoxElement<T>) -> SceneGraphUINode {
        self.addingIcon(IconLibrary.boundingBoxIcon)
    }

    func addingIcon<T: TupleElementType>(for element: T) -> SceneGraphUINode {
        self.addingIcon(IconLibrary.tupleIcon)
    }

    private class IconLibrary {
        // MARK: - Red icons (geometry primitives)

        static let aabbIcon: Image = makeAABBIcon(.red)

        static let sphereIcon: Image = makeIcon(.red) { (renderer, size) in
            let circle = UICircle(center: size.asUIPoint / 2, radius: size.width * 0.45)
            let horizon = circle.asUIEllipse.scaledBy(x: 1.0, y: 0.3).arc(start: .zero, sweep: .pi)
            let meridian = circle.asUIEllipse.scaledBy(x: 0.3, y: 1.0).arc(start: -.pi / 2, sweep: .pi)

            renderer.stroke(circle)
            renderer.stroke(horizon)
            renderer.stroke(meridian)
        }

        static let cylinderIcon: Image = makeIcon(.red) { (renderer, size) in
            let top = UIEllipse(
                center: .init(x: size.width / 2, y: size.height * 0.25),
                radius: .init(x: size.width / 2, y: size.height * 0.2)
            )
            let bottom = top
                .offsetBy(x: 0, y: size.height * 0.5)
                .arc(start: .zero, sweep: .pi)

            renderer.stroke(top)
            renderer.stroke(bottom)
            renderer.stroke(UILine(x1: top.bounds.left, y1: top.center.y, x2: top.bounds.left, y2: size.height * 0.75))
            renderer.stroke(UILine(x1: top.bounds.right, y1: top.center.y, x2: top.bounds.right, y2: size.height * 0.75))
        }

        static let diskIcon: Image = makeIcon(.red) { (renderer, size) in
            let disk = UICircle(center: size.asUIPoint / 2, radius: size.width * 0.45)
                .asUIEllipse
                .scaledBy(x: 0.6, y: 1.0)

            renderer.stroke(disk)
        }

        // MARK: - Blue icons (structural elements)

        static let repeatTranslateIcon: Image = makeIcon(.blue) { (renderer, size) in
            let circle1 = UICircle(center: size.asUIPoint * UIVector(x: 0.25, y: 0.25), radius: size.width * 0.22)
            let circle2 = circle1.offsetBy(x: size.width * 0.2, y: size.width * 0.2)
            let circle3 = circle2.offsetBy(x: size.width * 0.2, y: size.height * 0.2)

            renderer.setFill(.white)
            
            renderer.stroke(circle1)

            renderer.fill(circle2)
            renderer.stroke(circle2)

            renderer.fill(circle3)
            renderer.stroke(circle3)
        }

        static let boundingBoxIcon: Image = makeAABBIcon(.blue)

        static let tupleIcon: Image = makeIcon(.blue) { (renderer, size) in
            renderer.setStroke(.blue)

            let circleLeft = UICircle(
                center: .init(x: size.width, y: size.height / 2),
                radius: size.width - 2
            )
            let circleRight = UICircle(
                center: .init(x: 0, y: size.height / 2),
                radius: size.width - 2
            )

            renderer.stroke(circleLeft)
            renderer.stroke(circleRight)
        }

        // MARK: -

        private static func makeAABBIcon(_ color: Color) -> Image {
            makeIcon(color) { (renderer, size) in
                let aabb = UIRectangle(x: size.width * 0.1, y: size.height * 0.4, width: size.width * 0.6, height: size.height * 0.4)
                var polygon = UIPolygon()
                polygon.addVertex(aabb.topLeft)
                polygon.addVertex(aabb.topRight)
                polygon.addVertex(aabb.bottomRight)
                polygon.addVertex(aabb.bottomLeft)
                polygon.close()

                let topEdge =
                    UILine(start: aabb.topLeft, end: aabb.topRight)
                        .offsetBy(x: size.width * 0.2, y: -size.height * 0.2)
                let rightEdge =
                    UILine(start: aabb.topRight, end: aabb.bottomRight)
                        .offsetBy(x: size.width * 0.2, y: -size.height * 0.2)

                renderer.stroke(polygon)
                renderer.stroke(topEdge)
                renderer.stroke(rightEdge)
                renderer.strokeLine(start: aabb.topLeft, end: topEdge.start)
                renderer.strokeLine(start: aabb.topRight, end: topEdge.end)
                renderer.strokeLine(start: aabb.bottomRight, end: rightEdge.end)
            }
        }

        private static func makeIcon(_ color: Color, rendering closure: (Renderer, UISize) -> Void) -> Image {
            let size = UIIntSize(width: 12, height: 12)
            let context = Blend2DRendererContext().createImageRenderer(width: size.width, height: size.height)
            context.renderer.clear()
            context.renderer.setStroke(color)

            closure(context.renderer, UISize(size))

            return context.renderedImage()
        }
    }
}

// MARK: - SceneGraphVisitor

private class SceneGraphVisitor: ElementVisitor {
    typealias ResultType = SceneGraphUINode

    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement {
        SceneGraphUINode(element: element, title: "\(type(of: element))")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit<T>(_ element: T) -> ResultType where T: Element {
        SceneGraphUINode(element: element, title: "\(type(of: element))")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType {
        SceneGraphUINode(element: element, title: "AABB")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: CubeElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Cube")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: CylinderElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Cylinder")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: DiskElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Disk")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: EllipseElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Ellipse")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: EmptyElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Empty element")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Generic geometry")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Line segment")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: PlaneElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Plane")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: SphereElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Sphere")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: TorusElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Torus")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Bounding Box")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Bounding Sphere")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Bounded typed array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Intersection")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Subtraction")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Typed array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Union")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Repeat Translating")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Transforming

    func visit<T>(_ element: ScaleElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Scale")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T>(_ element: TranslateElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Translate")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "2 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "2 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        SceneGraphUINode(element: element, title: "3 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        SceneGraphUINode(element: element, title: "3 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphUINode(element: element, title: "4 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphUINode(element: element, title: "4 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphUINode(element: element, title: "5 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphUINode(element: element, title: "5 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphUINode(element: element, title: "6 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphUINode(element: element, title: "6 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphUINode(element: element, title: "7 Elements Tuple")
            .addingIcon(for: element)
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
        SceneGraphUINode(element: element, title: "7 Elements Bounded Tuple")
            .addingIcon(for: element)
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
        SceneGraphUINode(element: element, title: "8 Elements Tuple")
            .addingIcon(for: element)
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
        SceneGraphUINode(element: element, title: "8 Elements Bounded Tuple")
            .addingIcon(for: element)
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
        SceneGraphUINode(element: element, title: "Bounding Box")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: BoundingSphereElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Bounding Sphere")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Combination

    func visit<T: RaymarchingElement>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Bounded typed array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Intersection")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Subtraction")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: TypedArrayElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Typed array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: UnionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Union")
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T: RaymarchingElement>(_ element: RepeatTranslateElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Repeat Translating")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Transforming

    func visit<T: RaymarchingElement>(_ element: ScaleElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Scale")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }
    func visit<T: RaymarchingElement>(_ element: TranslateElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Translate")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleRaymarchingElement2<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "2 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement {
        SceneGraphUINode(element: element, title: "2 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
    
    func visit<T0, T1, T2>(_ element: TupleRaymarchingElement3<T0, T1, T2>) -> ResultType {
        SceneGraphUINode(element: element, title: "3 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement {
        SceneGraphUINode(element: element, title: "3 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleRaymarchingElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphUINode(element: element, title: "4 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement {
        SceneGraphUINode(element: element, title: "4 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleRaymarchingElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphUINode(element: element, title: "5 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement {
        SceneGraphUINode(element: element, title: "5 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleRaymarchingElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphUINode(element: element, title: "6 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement {
        SceneGraphUINode(element: element, title: "6 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
            .addingSubNode(element.t2.accept(self))
            .addingSubNode(element.t3.accept(self))
            .addingSubNode(element.t4.accept(self))
            .addingSubNode(element.t5.accept(self))
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphUINode(element: element, title: "7 Elements Tuple")
            .addingIcon(for: element)
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
        SceneGraphUINode(element: element, title: "7 Elements Bounded Tuple")
            .addingIcon(for: element)
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
        SceneGraphUINode(element: element, title: "8 Elements Tuple")
            .addingIcon(for: element)
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
        SceneGraphUINode(element: element, title: "8 Elements Bounded Tuple")
            .addingIcon(for: element)
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
        SceneGraphUINode(element: element, title: "Array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }

    func visit(_ element: BoundedArrayRaymarchingElement) -> ResultType {
        SceneGraphUINode(element: element, title: "Bounded array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(element.elements.map { $0.accept(self) })
    }

    func visit<T>(_ element: AbsoluteRaymarchingElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Absolute distance")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    func visit<T0, T1>(_ element: OperationRaymarchingElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Custom operation")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    // MARK: Repeating

    func visit<T>(_ element: ModuloRaymarchingElement<T>) -> ResultType {
        SceneGraphUINode(element: element, title: "Modulo")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.element.accept(self))
    }

    // MARK: Smoothing

    func visit<T0, T1>(_ element: SmoothIntersectionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Smooth intersection")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    func visit<T0, T1>(_ element: SmoothUnionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Smooth union")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }

    func visit<T0, T1>(_ element: SmoothSubtractionElement<T0, T1>) -> ResultType {
        SceneGraphUINode(element: element, title: "Smooth subtraction")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(element.t0.accept(self))
            .addingSubNode(element.t1.accept(self))
    }
}
