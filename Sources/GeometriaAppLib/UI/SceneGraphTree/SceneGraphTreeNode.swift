import ImagineUI
import Text
import Blend2DRenderer
#if canImport(Geometria)
import Geometria
#endif

final class SceneGraphTreeNode {
    var object: NodeOwner
    var title: String
    var icon: Image?
    var properties: [PropertyEntry] = []
    var subnodes: [SceneGraphTreeNode] = []

    var mutator: ((NodeOwner) -> NodeOwner)?

    weak var parent: SceneGraphTreeNode?

    init(element: Element, title: String) {
        self.object = .element(element)
        self.title = title
    }
    
    init(matrix: RMatrix3x3, title: String) {
        self.object = .matrix3x3(matrix)
        self.title = title
    }
    
    init(material: Material, title: String) {
        self.object = .material(material)
        self.title = title
    }
    
    private init(object: NodeOwner, title: String) {
        self.object = object
        self.title = title
    }

    func addProperty<Value>(name: String, value: Value) {
        addProperty(name: name, value: String(describing: value))
    }

    func addProperty(name: String, value: String) {
        addProperty(name: name, text: AttributedText(value))
    }

    func addProperty(name: String, text: AttributedText) {
        properties.append(.init(name: name, value: text))
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

    func addSubNode<Base: Element, Value: Element>(
        _ node: SceneGraphTreeNode,
        mutating keyPath: WritableKeyPath<Base, Value>
    ) {
        
        addSubNode(node)

        self.mutator = { [weak self] newValue in
            guard let self = self else { return newValue }

            guard case .element(var castObject as Base) = self.object else {
                return newValue
            }
            guard let value = newValue as? Value else {
                return newValue
            }

            castObject[keyPath: keyPath] = value
            return .element(castObject)
        }
    }

    func addSubNodes<S: Sequence>(_ nodes: S) where S.Element == SceneGraphTreeNode {
        for node in nodes {
            addSubNode(node)
        }
    }

    func addingProperty<Value>(name: String, value: Value) -> SceneGraphTreeNode {
        addingProperty(name: name, value: String(describing: value))
    }

    func addingProperty(name: String, value: String) -> SceneGraphTreeNode {
        addingProperty(name: name, text: AttributedText(value))
    }

    func addingProperty(name: String, text: AttributedText) -> SceneGraphTreeNode {
        properties.append(.init(name: name, value: text))

        return self
    }

    func addingSubNode<Base: Element, Value: Element>(
        _ visitor: SceneGraphVisitor,
        mutating element: Base,
        _ keyPath: WritableKeyPath<Base, Value>
    ) -> SceneGraphTreeNode {
        
        addSubNode(element[keyPath: keyPath].accept(visitor), mutating: keyPath)

        return self
    }

    func addingSubNode<Base: Element, Value: RaymarchingElement>(
        _ visitor: SceneGraphVisitor,
        mutating element: Base,
        _ keyPath: WritableKeyPath<Base, Value>
    ) -> SceneGraphTreeNode {
        
        addSubNode(element[keyPath: keyPath].accept(visitor), mutating: keyPath)

        return self
    }

    func addingSubNodes<Base: Element, Value: Element>(
        _ visitor: SceneGraphVisitor,
        mutating element: Base,
        _ keyPath: WritableKeyPath<Base, [Value]>
    ) -> SceneGraphTreeNode {
        
        var result = self

        let elements = element[keyPath: keyPath]
        for index in 0..<elements.count {
            let kp = keyPath.appending(path: \.[index])

            result = result.addingSubNode(
                visitor,
                mutating: element,
                kp
            )
        }

        return result
    }
    
    func addingCustomSubNode(
        title: String,
        _ builder: (inout SceneGraphTreeNode) -> Void
    ) -> SceneGraphTreeNode {
        
        var node = SceneGraphTreeNode(object: object, title: title)
        builder(&node)
        
        let result = self
        
        result.addSubNode(node)
        
        return result
    }
    
    func addingCustomSubNode(
        matrix: RMatrix3x3,
        title: String,
        _ builder: (inout SceneGraphTreeNode) -> Void
    ) -> SceneGraphTreeNode {
        
        var node = SceneGraphTreeNode(matrix: matrix, title: title)
        builder(&node)
        
        let result = self
        
        result.addSubNode(node)
        
        return result
    }
    
    func addingIcon(_ icon: Image?) -> SceneGraphTreeNode {
        self.icon = icon

        return self
    }

    struct PropertyEntry {
        var name: String
        var value: AttributedText
    }
    
    enum NodeOwner {
        case element(Element)
        case matrix3x3(RMatrix3x3)
        case material(Material)
    }
}

// MARK: - Property derivation

extension SceneGraphTreeNode {
    // MARK: - Data type properties

    func addingProperty(name: String, value: RVector3D) -> SceneGraphTreeNode {
        func fade(_ c: Color) -> Color {
            c.faded(towards: .white, factor: 0.8)
        }

        var text = AttributedText()
        text.append("(")
        text.append("\(value.x)", attributes: [.foregroundColor: fade(Color.red)])
        text.append(", ")
        text.append("\(value.y)", attributes: [.foregroundColor: fade(Color.green)])
        text.append(", ")
        text.append("\(value.z)", attributes: [.foregroundColor: fade(Color.blue)])
        text.append(")")

        return addingProperty(name: name, text: text)
    }

    func addingProperty(name: String, value: BLRgba32) -> SceneGraphTreeNode {
        // Find a complimentary color for the text
        let color = value.asColor
        let luma = 0.2126 * Double(color.red) + 0.7152 * Double(color.green) + 0.0722 * Double(color.blue)
        let textColor: Color = luma > 0.5 ? .black : .white

        return addingProperty(
            name: name,
            text: "\(value, attributes: [.backgroundColor: color, .foregroundColor: textColor])"
        )
    }
    
    func addingMatrixProperty(name: String, value: RMatrix3x3) -> SceneGraphTreeNode {
        addingCustomSubNode(matrix: value, title: name) { node in
            node.icon = IconLibrary.matrixIcon

            let rows = value.rows()
            
            for (i, row) in rows.enumerated() {
                node.addProperty(
                    name: "row \(i)",
                    value: "(\(row.map { "\($0)" }.joined(separator: ", ")))"
                )
            }
        }
    }
    
    func addingMatrixProperty<M: MatrixType>(name: String, value: M) -> SceneGraphTreeNode {
        addingCustomSubNode(title: name) { node in
            node.icon = IconLibrary.matrixIcon

            let rows = value.rows()
            
            for (i, row) in rows.enumerated() {
                node.addProperty(
                    name: "row \(i)",
                    value: "(\(row.map { "\($0)" }.joined(separator: ", ")))"
                )
            }
        }
    }

    func addingMaterialProperty(
        material id: MaterialId?,
        map: MaterialMap?
    ) -> SceneGraphTreeNode {
        guard let id = id, let material = map?[id] else {
            return self
        }

        return addingMaterialProperty(material: material)
    }

    func addingMaterialProperty(
        material: Material
    ) -> SceneGraphTreeNode {
        var node = SceneGraphTreeNode(material: material, title: "Material")

        switch material {
        case .diffuse(let diffuse):
            node = node
                .addingProperty(name: "Type", value: "Diffuse")
                .addingProperties(for: diffuse)

        case .checkerboard(let size, let color1, let color2):
            node = node
                .addingProperty(name: "Type", value: "Checkerboard")
                .addingProperty(name: "Size", value: size)
                .addingProperty(name: "Color 1", value: color1)
                .addingProperty(name: "Color 2", value: color2)
        
        case .target(let center, let stripeFrequency, let color1, let color2):
            node = node
                .addingProperty(name: "Type", value: "Target")
                .addingProperty(name: "Center", value: center)
                .addingProperty(name: "Stripe Frequency", value: stripeFrequency)
                .addingProperty(name: "Color 1", value: color1)
                .addingProperty(name: "Color 2", value: color2)
        }

        let result = self
        result.addSubNode(node)
        
        return result
    }

    func addingProperties(for diffuse: DiffuseMaterial) -> SceneGraphTreeNode {
        self.addingProperty(name: "Color", value: diffuse.color)
            .addingProperty(name: "Bump Noise Frequency", value: diffuse.bumpNoiseFrequency)
            .addingProperty(name: "Bump Magnitude", value: diffuse.bumpMagnitude)
            .addingProperty(name: "Reflectivity", value: diffuse.reflectivity)
            .addingProperty(name: "Transparency", value: diffuse.transparency)
            .addingProperty(name: "Refractive Index", value: diffuse.refractiveIndex)
    }

    // MARK: Scene element properties

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
    
    func addingProperties<T: GeometryElementType>(for element: T) -> SceneGraphTreeNode where T.GeometryType == RHyperplane3D {
        self.addingProperty(name: "Origin", value: element.geometry.point)
            .addingProperty(name: "Normal", value: element.geometry.normal)
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
    
    func addingProperties<T>(for element: RotateElement<T>) -> SceneGraphTreeNode {
        self.addingMatrixProperty(name: "Matrix", value: element.rotation)
            .addingProperty(name: "Center", value: element.rotationCenter)
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
}

// MARK: - SceneGraphVisitor

class SceneGraphVisitor: ElementVisitor {
    typealias ResultType = SceneGraphTreeNode

    let materialMap: MaterialMap?

    init(materialMap: MaterialMap?) {
        self.materialMap = materialMap
    }

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
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: CubeElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Cube")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: CylinderElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Cylinder")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: DiskElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Disk")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: EllipseElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Ellipse")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
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
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: LineSegmentElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Line segment")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: PlaneElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Plane")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: SphereElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Sphere")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: TorusElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Torus")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
    }
    func visit(_ element: HyperplaneElement) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Hyperplane")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
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
            .addingMaterialProperty(material: element.material, map: materialMap)
            .addingSubNode(self, mutating: element, \.t0)
            .addingSubNode(self, mutating: element, \.t1)
    }
    func visit<T0, T1>(_ element: SubtractionElement<T0, T1>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Subtraction")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingMaterialProperty(material: element.material, map: materialMap)
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
            .addingMaterialProperty(material: element.material, map: materialMap)
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

    func visit<T>(_ element: RotateElement<T>) -> ResultType {
        SceneGraphTreeNode(element: element, title: "Rotate")
            .addingIcon(for: element)
            .addingProperties(for: element)
            .addingSubNode(self, mutating: element, \.element)
    }
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
