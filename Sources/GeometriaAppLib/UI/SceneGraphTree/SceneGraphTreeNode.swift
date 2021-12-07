import ImagineUI
import Blend2DRenderer

final class SceneGraphTreeNode {
    var element: Element
    var title: String
    var icon: Image?
    var properties: [PropertyEntry] = []
    var subnodes: [SceneGraphTreeNode] = []

    var mutator: ((Element) -> Element)?

    weak var parent: SceneGraphTreeNode?

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

    func addSubNode(_ node: SceneGraphTreeNode) {
        assert(node !== self)

        node.parent = self
        subnodes.append(node)
    }

    /*
    func addSubNode<Base: Element, Value: Element>(_ node: SceneGraphTreeNode, keyPath: WritableKeyPath<Base, Value>, mutator: (Value) -> Base) {
        addSubNode(node)

        self.mutator = { [weak self] newValue in
            guard let self = self else { return newValue }

            guard var castObject = self.element as? Base else {
                return newValue
            }
            guard let value = newValue as? Value else {
                return newValue
            }

            castObject[keyPath: keyPath] = value
            return castObject
        }
    }
    */

    func addSubNode<Base: Element, Value: Element>(_ node: SceneGraphTreeNode, mutating keyPath: WritableKeyPath<Base, Value>) {
        addSubNode(node)

        self.mutator = { [weak self] newValue in
            guard let self = self else { return newValue }

            guard var castObject = self.element as? Base else {
                return newValue
            }
            guard let value = newValue as? Value else {
                return newValue
            }

            castObject[keyPath: keyPath] = value
            return castObject
        }
    }

    func addSubNodes<S: Sequence>(_ nodes: S) where S.Element == SceneGraphTreeNode {
        for node in nodes {
            addSubNode(node)
        }
    }

    func addingProperty(name: String, value: String) -> SceneGraphTreeNode {
        properties.append(.init(name: name, value: value))

        return self
    }

    func addingProperty<Value>(name: String, value: Value) -> SceneGraphTreeNode {
        properties.append(.init(name: name, value: String(describing: value)))

        return self
    }

    func addingSubNode<Base: Element, Value: Element>(_ visitor: SceneGraphVisitor, mutating element: Base, _ keyPath: WritableKeyPath<Base, Value>) -> SceneGraphTreeNode {
        addSubNode(element[keyPath: keyPath].accept(visitor), mutating: keyPath)

        return self
    }

    func addingSubNode<Base: Element, Value: RaymarchingElement>(_ visitor: SceneGraphVisitor, mutating element: Base, _ keyPath: WritableKeyPath<Base, Value>) -> SceneGraphTreeNode {
        addSubNode(element[keyPath: keyPath].accept(visitor), mutating: keyPath)

        return self
    }

    func addingSubNodes<Base: Element, Value: Element>(_ visitor: SceneGraphVisitor, mutating element: Base, _ keyPath: WritableKeyPath<Base, [Value]>) -> SceneGraphTreeNode {
        var result = self

        let elements = element[keyPath: keyPath]
        for index in 0..<elements.count {
            let kp = keyPath.appending(path: \.[index])

            result = result.addingSubNode(visitor, mutating: element, kp)
        }

        return result
    }

    func addingIcon(_ icon: Image?) -> SceneGraphTreeNode {
        self.icon = icon

        return self
    }

    struct PropertyEntry {
        var name: String
        var value: String
    }
}

// MARK: - Property derivation

extension SceneGraphTreeNode {
    func addingProperty(name: String, value: RVector3D) -> SceneGraphTreeNode {
        addingProperty(name: name, value: "(\(value.x), \(value.y), \(value.z))")
    }

    func addingProperties<T: Element>(for element: T) -> SceneGraphTreeNode {
        return self
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphTreeNode where T.GeometryType == RSphere3D {
        self.addingProperty(name: "Center", value: element.geometry.center)
            .addingProperty(name: "Radius", value: element.geometry.radius)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphTreeNode where T.GeometryType == RCube3D {
        self.addingProperty(name: "Origin", value: element.geometry.location)
            .addingProperty(name: "Length", value: element.geometry.sideLength)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphTreeNode where T.GeometryType == RTorus3D {
        self.addingProperty(name: "Major", value: element.geometry.majorRadius)
            .addingProperty(name: "Minor", value: element.geometry.minorRadius)
            .addingProperty(name: "Axis", value: element.geometry.axis)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphTreeNode where T.GeometryType == RAABB3D {
        self.addingProperty(name: "Minimum", value: element.geometry.minimum)
            .addingProperty(name: "Maximum", value: element.geometry.maximum)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphTreeNode where T.GeometryType == RPlane3D {
        self.addingProperty(name: "Origin", value: element.geometry.point)
            .addingProperty(name: "Normal", value: element.geometry.normal)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphTreeNode where T.GeometryType == RDisk3D {
        self.addingProperty(name: "Center", value: element.geometry.center)
            .addingProperty(name: "Radius", value: element.geometry.radius)
            .addingProperty(name: "Normal", value: element.geometry.normal)
    }

    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphTreeNode where T.GeometryType == RCylinder3D {
        self.addingProperty(name: "Start", value: element.geometry.start)
            .addingProperty(name: "End", value: element.geometry.end)
            .addingProperty(name: "Radius", value: element.geometry.radius)
    }

    
    func addingProperties<T>(for element: BoundingBoxElement<T>) -> SceneGraphTreeNode {
        self.addingProperty(name: "Bounds", value: element.boundingBox)
    }

    func addingProperties<T>(for element: BoundingSphereElement<T>) -> SceneGraphTreeNode {
        self.addingProperty(name: "Bounds", value: element.boundingSphere)
    }

    func addingProperties<T>(for element: RepeatTranslateElement<T>) -> SceneGraphTreeNode {
        self.addingProperty(name: "Translation", value: element.translation)
            .addingProperty(name: "Count", value: element.count)
    }

    func addingProperties<T>(for element: ScaleElement<T>) -> SceneGraphTreeNode {
        self.addingProperty(name: "Factor", value: element.scaling)
            .addingProperty(name: "Center", value: element.scalingCenter)
    }

    func addingProperties<T>(for element: TranslateElement<T>) -> SceneGraphTreeNode {
        self.addingProperty(name: "Translation", value: element.translation)
    }
}

// MARK: - Icon derivation

extension SceneGraphTreeNode {
    func addingIcon<T: Element>(for element: T) -> SceneGraphTreeNode {
        return self
    }

    func addingIcon(for element: CubeElement) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.cubeIcon)
    }

    func addingIcon(for element: AABBElement) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.aabbIcon)
    }

    func addingIcon(for element: SphereElement) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.sphereIcon)
    }

    func addingIcon(for element: CylinderElement) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.cylinderIcon)
    }

    func addingIcon(for element: DiskElement) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.diskIcon)
    }

    func addingIcon<T>(for element: RepeatTranslateElement<T>) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.repeatTranslateIcon)
    }

    func addingIcon<T>(for element: BoundingBoxElement<T>) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.boundingBoxIcon)
    }

    func addingIcon<T: TupleElementType>(for element: T) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.tupleIcon)
    }

    func addingIcon<T0, T1>(for element: IntersectionElement<T0, T1>) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.intersectionIcon)
    }

    func addingIcon<T0, T1>(for element: SubtractionElement<T0, T1>) -> SceneGraphTreeNode {
        self.addingIcon(IconLibrary.subtractionIcon)
    }

    private class IconLibrary {
        // MARK: - Red icons (geometry primitives)

        static let aabbIcon: Image = makeAABBIcon(.lightCoral)

        static let cubeIcon: Image = makeAABBIcon(.lightCoral, aabbSizeScale: .init(x: 0.6, y: 0.6))

        static let sphereIcon: Image = makeIcon(.lightCoral) { (renderer, size) in
            let circle = UICircle(center: size.asUIPoint / 2, radius: size.width * 0.45)
            let horizon = circle.asUIEllipse.scaledBy(x: 1.0, y: 0.3).arc(start: .zero, sweep: .pi)
            let meridian = circle.asUIEllipse.scaledBy(x: 0.3, y: 1.0).arc(start: -.pi / 2, sweep: .pi)

            renderer.stroke(circle)
            renderer.stroke(horizon)
            renderer.stroke(meridian)
        }

        static let cylinderIcon: Image = makeIcon(.lightCoral) { (renderer, size) in
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

        static let diskIcon: Image = makeIcon(.lightCoral) { (renderer, size) in
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

        static let boundingBoxIcon: Image = makeAABBIcon(.cornflowerBlue)

        static let tupleIcon: Image = makeIcon(.cornflowerBlue) { (renderer, size) in
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

        static let intersectionIcon: Image = makeIcon(.cornflowerBlue) { (renderer, size) in
            let sizePoint = size.asUIPoint
            
            let square = UIRectangle(location: sizePoint * 0.2, size: size * 0.6)
            let circle = UICircle(center: square.bottomRight, radius: square.width * 0.65)
            let pie = circle.arc(start: -.pi / 2, sweep: -.pi / 2)
        
            renderer.withTemporaryState {
                renderer.setStroke(.lightGray.withTransparency(30))
                renderer.stroke(square)
                renderer.stroke(circle)
            }

            renderer.stroke(pie: pie)
        }

        static let subtractionIcon: Image = makeIcon(.cornflowerBlue) { (renderer, size) in
            let sizePoint = size.asUIPoint

            var poly = UIPolygon(vertices: [
                sizePoint * 0.2,
                sizePoint * UIVector(x: 0.8, y: 0.2),
                sizePoint * UIVector(x: 0.8, y: 0.5),
                sizePoint * UIVector(x: 0.5, y: 0.5),
                sizePoint * UIVector(x: 0.5, y: 0.8),
                sizePoint * UIVector(x: 0.2, y: 0.8),
            ])
            poly.close()

            renderer.stroke(poly)
        }

        // MARK: -

        private static func makeAABBIcon(_ color: Color, aabbSizeScale: UIVector = UIVector(x: 0.6, y: 0.4)) -> Image {
            makeIcon(color) { (renderer, size) in
                let aabb = UIRectangle(x: size.width * 0.1, y: size.height * 0.4, width: size.width * aabbSizeScale.x, height: size.height * aabbSizeScale.y)
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

class SceneGraphVisitor: ElementVisitor {
    typealias ResultType = SceneGraphTreeNode

    // MARK: Generic elements

    func visit<T>(_ element: T) -> ResultType where T: BoundedElement {
        SceneGraphTreeNode(element: element, title: "\(type(of: element))")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit<T>(_ element: T) -> ResultType where T: Element {
        SceneGraphTreeNode(element: element, title: "\(type(of: element))")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }

    // MARK: Basic

    func visit(_ element: AABBElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "AABB")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: CubeElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Cube")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: CylinderElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Cylinder")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: DiskElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Disk")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: EllipseElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Ellipse")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: EmptyElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Empty element")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit<T>(_ element: GeometryElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Generic geometry")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Line segment")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: PlaneElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Plane")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: SphereElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Sphere")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }
    func visit(_ element: TorusElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Torus")
            .addingIcon(for: element)
            .addingProperties(for: element)
    }

    // MARK: Bounding

    func visit<T>(_ element: BoundingBoxElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Bounding Box")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }
    func visit<T>(_ element: BoundingSphereElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Bounding Sphere")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }

    // MARK: Combination

    func visit<T>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Bounded typed array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(self, mutating: element, \.elements)
    }
    func visit<T0, T1>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Intersection")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Subtraction")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    func visit<T>(_ element: TypedArrayElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Typed array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(self, mutating: element, \.elements)
    }
    func visit<T0, T1>(_ element: UnionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Union")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }

    // MARK: Repeating

    func visit<T>(_ element: RepeatTranslateElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Repeat Translating")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }

    // MARK: Transforming

    func visit<T>(_ element: ScaleElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Scale")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }
    func visit<T>(_ element: TranslateElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Translate")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleElement2<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "2 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "2 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    
    func visit<T0, T1, T2>(_ element: TupleElement3<T0, T1, T2>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "3 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "3 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "4 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "4 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "5 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "5 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "6 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "6 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "7 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
            .addingSubNode(self, mutating: element, \.t6)
    }
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "7 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
            .addingSubNode(self, mutating: element, \.t6)
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "8 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
            .addingSubNode(self, mutating: element, \.t6)
            .addingSubNode(self, mutating: element, \.t7)
    }
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "8 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
            .addingSubNode(self, mutating: element, \.t6)
            .addingSubNode(self, mutating: element, \.t7)
    }
}

extension SceneGraphVisitor: RaymarchingElementVisitor {
    // MARK: Bounding

    func visit<T: RaymarchingElement>(_ element: BoundingBoxElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Bounding Box")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }
    func visit<T: RaymarchingElement>(_ element: BoundingSphereElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Bounding Sphere")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }

    // MARK: Combination

    func visit<T: RaymarchingElement>(_ element: BoundedTypedArrayElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Bounded typed array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(self, mutating: element, \.elements)
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: IntersectionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Intersection")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Subtraction")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    func visit<T: RaymarchingElement>(_ element: TypedArrayElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Typed array")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNodes(self, mutating: element, \.elements)
    }
    func visit<T0: RaymarchingElement, T1: RaymarchingElement>(_ element: UnionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Union")
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }

    // MARK: Repeating

    func visit<T: RaymarchingElement>(_ element: RepeatTranslateElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Repeat Translating")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }

    // MARK: Transforming

    func visit<T: RaymarchingElement>(_ element: ScaleElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Scale")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }
    func visit<T: RaymarchingElement>(_ element: TranslateElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Translate")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }

    // MARK: Tuple Elements
    
    func visit<T0, T1>(_ element: TupleRaymarchingElement2<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "2 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    func visit<T0, T1>(_ element: BoundedTupleElement2<T0, T1>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement {
        SceneGraphTreeNode(element: element, title: "2 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    
    func visit<T0, T1, T2>(_ element: TupleRaymarchingElement3<T0, T1, T2>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "3 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
    }
    func visit<T0, T1, T2>(_ element: BoundedTupleElement3<T0, T1, T2>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement {
        SceneGraphTreeNode(element: element, title: "3 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
    }
    
    func visit<T0, T1, T2, T3>(_ element: TupleRaymarchingElement4<T0, T1, T2, T3>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "4 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
    }
    func visit<T0, T1, T2, T3>(_ element: BoundedTupleElement4<T0, T1, T2, T3>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement {
        SceneGraphTreeNode(element: element, title: "4 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
    }

    func visit<T0, T1, T2, T3, T4>(_ element: TupleRaymarchingElement5<T0, T1, T2, T3, T4>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "5 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
    }
    func visit<T0, T1, T2, T3, T4>(_ element: BoundedTupleElement5<T0, T1, T2, T3, T4>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement {
        SceneGraphTreeNode(element: element, title: "5 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
    }
    
    func visit<T0, T1, T2, T3, T4, T5>(_ element: TupleRaymarchingElement6<T0, T1, T2, T3, T4, T5>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "6 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
    }
    func visit<T0, T1, T2, T3, T4, T5>(_ element: BoundedTupleElement6<T0, T1, T2, T3, T4, T5>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement {
        SceneGraphTreeNode(element: element, title: "6 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: TupleRaymarchingElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "7 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
            .addingSubNode(self, mutating: element, \.t6)
    }
    func visit<T0, T1, T2, T3, T4, T5, T6>(_ element: BoundedTupleElement7<T0, T1, T2, T3, T4, T5, T6>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T6: RaymarchingElement {
        SceneGraphTreeNode(element: element, title: "7 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
            .addingSubNode(self, mutating: element, \.t6)
    }
    
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: TupleRaymarchingElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "8 Elements Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
            .addingSubNode(self, mutating: element, \.t6)
            .addingSubNode(self, mutating: element, \.t7)
    }
    func visit<T0, T1, T2, T3, T4, T5, T6, T7>(_ element: BoundedTupleElement8<T0, T1, T2, T3, T4, T5, T6, T7>) -> ResultType where T0: RaymarchingElement, T1: RaymarchingElement, T2: RaymarchingElement, T3: RaymarchingElement, T4: RaymarchingElement, T5: RaymarchingElement, T7: RaymarchingElement {
        SceneGraphTreeNode(element: element, title: "8 Elements Bounded Tuple")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
            .addingSubNode(self, mutating: element, \.t2)
            .addingSubNode(self, mutating: element, \.t3)
            .addingSubNode(self, mutating: element, \.t4)
            .addingSubNode(self, mutating: element, \.t5)
            .addingSubNode(self, mutating: element, \.t6)
            .addingSubNode(self, mutating: element, \.t7)
    }

    // MARK: Combination
    func visit<T>(_ element: AbsoluteRaymarchingElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Absolute distance")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }

    func visit<T0, T1>(_ element: OperationRaymarchingElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Custom operation")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }

    // MARK: Repeating

    func visit<T>(_ element: ModuloRaymarchingElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Modulo")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }

    // MARK: Smoothing

    func visit<T0, T1>(_ element: SmoothIntersectionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Smooth intersection")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }

    func visit<T0, T1>(_ element: SmoothUnionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Smooth union")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }

    func visit<T0, T1>(_ element: SmoothSubtractionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Smooth subtraction")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
}
