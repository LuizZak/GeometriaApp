#if canImport(Geometria)
import Geometria
#endif

class ProcessingPrinter {
    typealias Transform3D = RMatrix4x4
    
    private var _lastStrokeColorCall: String? = ""
    private var _lastStrokeWeightCall: String? = ""
    private var _lastFillColorCall: String? = ""
    
    private let defaultPrintTarget: ProcessingPrinterTarget

    private let identDepth: Int = 2
    private var currentIndent: Int = 0
    private var draws: [String] = []
    var cylinders: [(Cylinder3<RVector3D>, comment: String?, transform: Transform3D?)] = []
    var shouldPrintDrawNormal: Bool = false
    var shouldPrintDrawTangent: Bool = false
    var is3D: Bool = false
    var hasCylinders: Bool { !cylinders.isEmpty }
    var hasDisks: Bool = false
    
    var buffer: String = ""
    
    var size: RVector2D
    var scale: Double
    
    var drawOrigin: Bool = true
    var drawGrid: Bool = false

    convenience init(size: ViewportSize, scale: Double = 25.0) {
        self.init(size: RVector2D(size), scale: scale)
    }
    
    init(size: RVector2D = .init(x: 800, y: 600), scale: Double = 25.0) {
        self.size = size
        self.scale = scale

        #if os(Windows)
        defaultPrintTarget = LogProcessingPrinterTarget()
        #else
        defaultPrintTarget = ConsoleProcessingPrinterTarget()
        #endif
    }
    
    func add<V: Vector2Type>(ellipse: Ellipsoid<V>) {
        addStrokeColorSet("0")
        addStrokeWeightSet("1 / scale")
        addNoFill()
        addDrawLine(Self.ellipse2String(ellipse))
        addDrawLine("")
    }
    
    func add<V: Vector3FloatingPoint>(ellipse3: Ellipsoid<V>, comment: String? = nil, transform: Transform3D? = nil) {
        is3D = true

        if let comment = comment {
            addDrawLine("// \(comment)")
        }

        addNoStroke()
        add3DSpaceBarBoilerplate(lineWeight: ellipse3.radius.maximalComponent)
        addDrawLine("pushMatrix();")
        addMatrixLine(transform)
        addDrawLine("translate(\(Self.vec3String(ellipse3.center)));")
        addDrawLine("scale(\(Self.vec3String(ellipse3.radius)));")
        addDrawLine("sphere(1);")
        addDrawLine("popMatrix();")
        addDrawLine("")
    }
    
    func add<Line: Line2Type>(line: Line) {
        addStrokeColorSet("0")
        addStrokeWeightSet("1 / scale")
        addDrawLine(Self.line2String(line))
        addDrawLine("")
    }
    
    func add<Vector: Vector3Type>(ray: DirectionalRay3<Vector>, comment: String? = nil) {
        is3D = true
        
        if let comment = comment {
            addDrawLine("// \(comment)")
        }

        addStrokeColorSet("255, 0, 0")
        addStrokeWeightSet("2 / scale")
        addDrawLine(Self.ray3String(ray))
        addDrawLine("")
    }
    
    func add<Line: Line3Type>(line: Line, color: String = "0", comment: String? = nil, transform: Transform3D? = nil) {
        is3D = true
        
        if let comment = comment {
            addDrawLine("// \(comment)")
        }

        addStrokeColorSet(color)
        addStrokeWeightSet("2 / scale")
        // TODO: Add transform matrix push
        addDrawLine(Self.line3String(line))
        addDrawLine("")
    }
    
    func add<V: Vector2Type>(intersection result: ConvexLineIntersection<V>) {
        switch result {
        case .contained, .noIntersection:
            break
            
        case .singlePoint(let pn), .enter(let pn), .exit(let pn):
            add(pointNormal: pn)
            
        case let .enterExit(p1, p2):
            add(pointNormal: p1)
            add(pointNormal: p2)
        }
    }
    
    func add<V: Vector3Type>(intersection result: ConvexLineIntersection<V>) where V.Scalar == Double {
        switch result {
        case .contained, .noIntersection:
            break
        case .singlePoint(let pn), .enter(let pn), .exit(let pn):
            add(pointNormal: pn)
        case let .enterExit(p1, p2):
            add(pointNormal: p1)
            add(pointNormal: p2)
        }
    }
    
    func add<V: Vector2Type>(pointNormal: PointNormal<V>) {
        shouldPrintDrawNormal = true
        shouldPrintDrawTangent = true
        
        addStrokeWeightSet("1 / scale")
        addStrokeColorSet("255, 0, 0, 100")
        addDrawLine(Self.pointNormal2String_normal(pointNormal))
        addStrokeColorSet("255, 0, 255, 100")
        addDrawLine(Self.pointNormal2String_tangent(pointNormal))
        addDrawLine("")
    }
    
    func add<V: Vector3Type>(pointNormal: PointNormal<V>) where V.Scalar == Double {
        shouldPrintDrawNormal = true
        
        add(sphere: Sphere3<V>(center: pointNormal.point, radius: 0.5))
        
        addStrokeWeightSet("1 / scale")
        addStrokeColorSet("255, 0, 0, 100")
        addDrawLine(Self.pointNormal3String_normal(pointNormal))
    }
    
    func add<V: Vector2Type>(circle: Circle2<V>) {
        addStrokeWeightSet("1 / scale")
        addStrokeColorSet("255, 0, 0, 100")
        addDrawLine(Self.circle2String(circle))
    }
    
    func add<V: Vector2Additive & VectorDivisible>(aabb: AABB2<V>) {
        addStrokeWeightSet("1 / scale")
        addStrokeColorSet("255, 0, 0, 100")
        addNoFill()
        addDrawLine(Self.aabb2String(aabb))
    }
    
    func add<V: Vector3Type>(sphere: Sphere3<V>, comment: String? = nil, transform: Transform3D? = nil) {
        is3D = true

        if let comment = comment {
            addDrawLine("// \(comment)")
        }
        
        let line = Self.sphere3String(sphere)
        
        if let transform = transform {
            addDrawLine("pushMatrix();")
            addMatrixLine(transform)
            addDrawLine(line)
            addDrawLine("popMatrix();")
        } else {
            addDrawLine(line)
        }
    }
    
    func add<V: Vector3Additive & VectorDivisible>(aabb: AABB3<V>, comment: String? = nil, transform: Transform3D? = nil) {
        is3D = true
        
        if let comment = comment {
            addDrawLine("// \(comment)")
        }
        
        add3DSpaceBarBoilerplate(lineWeight: 1.0)
        addDrawLine("pushMatrix();")
        addMatrixLine(transform)
        addDrawLine("translate(\(Self.vec3String(aabb.minimum + aabb.size / 2)));")
        addDrawLine("box(\(Self.vec3String(aabb.size)));")
        addDrawLine("popMatrix();")
    }
    
    func add(cylinder: Cylinder3<RVector3D>, comment: String? = nil, transform: Transform3D? = nil) {
        is3D = true
        
        cylinders.append((cylinder, comment, transform))
    }
    
    func add(disk: Disk3<RVector3D>, comment: String? = nil, transform: Transform3D? = nil) {
        is3D = true
        hasDisks = true

        if let comment = comment {
            addDrawLine("// \(comment)")
        }
        
        let line = Self.disk3String(disk)
        
        if let transform = transform {
            addDrawLine("pushMatrix();")
            addMatrixLine(transform)
            addDrawLine(line)
            addDrawLine("popMatrix();")
        } else {
            addDrawLine(line)
        }
    }

    func printAll(target: ProcessingPrinterTarget? = nil) {
        defer {
            printBuffer(
                target: target ?? defaultPrintTarget
            )
        }
        
        prepareCustomPreFile()
        
        if is3D {
            printLine("// 3rd party libraries:")
            printLine("// PeasyCam by Jonathan Feinberg")
            printLine("import peasy.*;")
            printLine("")
            printLine("// Shapes 3D by Peter Lager")
            printLine("import shapes3d.*;")
            printLine("import shapes3d.contour.*;")
            printLine("import shapes3d.org.apache.commons.math.*;")
            printLine("import shapes3d.org.apache.commons.math.geometry.*;")
            printLine("import shapes3d.path.*;")
            printLine("import shapes3d.utils.*;")
            printLine("")
        }
        
        printLine("float scale = \(scale);")
        if is3D {
            printLine("boolean isSpaceBarPressed = false;")
            printLine("PeasyCam cam;")
        }
        if hasCylinders {
            printLine("ArrayList<Cylinder> cylinders = new ArrayList<Cylinder>();")
        }
        
        printCustomHeader()
        
        printLine("")
        printSetup()
        printLine("")
        printDraw()
        
        if is3D {
            printLine("")
            printKeyPressed()
        }
        
        if drawGrid {
            printLine("")
            printDrawGrid2D()
        }
        
        if hasCylinders {
            printLine("")
            printAddCylinder()
            printLine("")
            printDrawCylinders()
        }
        
        if drawOrigin && is3D {
            printLine("")
            printDrawOrigin3D()
        }
        
        if shouldPrintDrawNormal {
            printLine("")
            printDrawNormal2D()
        }
        
        if shouldPrintDrawNormal && is3D {
            printLine("")
            printDrawNormal3D()
        }
        
        if shouldPrintDrawTangent {
            printLine("")
            printDrawTangent2D()
        }
        
        if is3D {
            printLine("")
            printDrawSphere()
        }

        if hasDisks {
            printLine("")
            printDrawDisk()
        }
        
        if hasCylinders {
            printLine("")
            printCylinderClass()
        }
    }
    
    // MARK: - Expression Printing
    
    func boilerplate3DSpaceBar<T: FloatingPoint>(lineWeight: T) -> [String] {
        return [
            "if (isSpaceBarPressed) {",
            indentString(depth: 1) + "noFill();",
            indentString(depth: 1) + "noLights();",
            indentString(depth: 1) + "stroke(0, 0, 0, 20);",
            indentString(depth: 1) + "strokeWeight(\(1 / lineWeight) / scale);",
            "} else {",
            indentString(depth: 1) + "noStroke();",
            indentString(depth: 1) + "fill(255, 255, 255, 255);",
            indentString(depth: 1) + "lights();",
            "}"
        ]
    }
    
    func addMatrixLine(_ matrix: RMatrix4x4?) {
        guard let matrix = matrix else {
            return
        }

        addDrawLine("applyMatrix(")
        indented {
            addDrawLine(mat2String(matrix, multiline: true))
        }
        addDrawLine(")")
    }
    
    func addDrawLine(_ line: String) {
        draws.append(line)
    }
    
    func addNoStroke() {
        if _lastStrokeColorCall == nil { return }
        _lastStrokeColorCall = nil
        addDrawLine("noStroke();")
    }
    
    func addNoFill() {
        if _lastFillColorCall == nil { return }
        _lastFillColorCall = nil
        addDrawLine("noFill();")
    }
    
    // TODO: Transform this boilerplate into a function in the output script
    // TODO: instead of creating a distinct copy every time.
    func add3DSpaceBarBoilerplate<T: FloatingPoint>(lineWeight: T) {
        boilerplate3DSpaceBar(lineWeight: lineWeight).forEach(addDrawLine(_:))
    }
    
    func addStrokeColorSet(_ value: String) {
        if _lastStrokeColorCall == value { return }
        
        _lastStrokeColorCall = value
        addDrawLine("stroke(\(value));")
    }
    
    func addStrokeWeightSet(_ value: String) {
        if _lastStrokeWeightCall == value { return }
        
        _lastStrokeWeightCall = value
        addDrawLine("strokeWeight(\(value));")
    }
    
    func addFillColorSet(_ value: String) {
        if _lastFillColorCall == value { return }
        
        _lastFillColorCall = value
        addDrawLine("fill(\(value));")
    }
    
    // MARK: - Methods for subclasses
    
    func prepareCustomPreFile() {
        
    }
    
    func printCustomHeader() {
        
    }
    
    func printCustomPostSetup() {
        
    }
    
    func printCustomPreDraw() {
        
    }
    
    func printCustomPostDraw() {
        
    }
    
    // MARK: - Function Printing
    
    func printSetup() {
        func registerCylinder(_ cylinder: Cylinder3<RVector3D>, comment: String?, transform: Transform3D?) {
            if let comment = comment {
                printLine("// \(comment)")
            }

            let start = Self.vec3PVectorString(cylinder.start)
            let end = Self.vec3PVectorString(cylinder.end)
            
            var line = "addCylinder(\(start), \(end), \(cylinder.radius)"
            
            if let transform = transform {
                line += ", " + mat2ArrayString(transform, multiline: true)
            }
            
            line += ");"
            
            printLine(line)
        }
        
        indentedBlock("void setup() {") {
            if is3D {
                printLine("size(\(Self.vec2String_int(size)), P3D);")
                printLine("perspective(PI / 3, 1, 0.3, 8000); // Corrects default zNear plane being too far for unit measurements")
                printLine("cam = new PeasyCam(this, 250);")
                printLine("cam.setWheelScale(0.3);")
            } else {
                printLine("size(\(Self.vec2String_int(size)));")
            }
            
            for cylinder in cylinders {
                registerCylinder(cylinder.0, comment: cylinder.comment, transform: cylinder.transform)
            }
            
            printLine("ellipseMode(RADIUS);")
            
            printCustomPostSetup()
        }
    }
    
    func printDraw() {
        indentedBlock("void draw() {") {
            printCustomPreDraw()
            
            printLine("background(255);")
            printLine("")
            if !is3D {
                printLine("translate(width / 2, height / 2);")
                printLine("scale(scale);")
            } else {
                printLine("// Correct Y to grow away from the origin, and Z to grow up")
                printLine("rotateX(PI / 2);")
                printLine("scale(1, -1, 1);")
            }
            printLine("")
            printLine("strokeWeight(3 / scale);")
            
            if drawGrid {
                printLine("drawGrid();")
            }
            if drawOrigin && is3D {
                printLine("drawOrigin();")
            }
            
            printLine("")
            
            for draw in draws {
                printLine(draw)
            }
            
            if hasCylinders {
                printLine("drawCylinders();")
            }
            
            printCustomPostDraw()
        }
    }
    
    func printKeyPressed() {
        indentedBlock("void keyPressed() {") {
            indentedBlock("if (key == ' ') {") {
                printLine("isSpaceBarPressed = !isSpaceBarPressed;")
            }
            
            if hasCylinders {
                indentedBlock("for (Cylinder cyl: cylinders) {") {
                    indentedBlock("if (isSpaceBarPressed) {") {
                        printLine("cyl.tube.drawMode(S3D.WIRE);")
                    }
                    printLine("else")
                    indentedBlock("{") {
                        printLine("cyl.tube.drawMode(S3D.SOLID);")
                    }
                }
            }
        }
    }
    
    func printAddCylinder() {
        indentedBlock("void addCylinder(PVector start, PVector end, float radius, float[] mat) {") {
            printLine("Oval base = new Oval(radius, 20);")
            printLine("Path line = new Linear(start, end, 1);")
            printLine("")
            printLine("Tube tube = new Tube(line, base);")
            printLine("")
            printLine("tube.drawMode(S3D.SOLID);")
            printLine("tube.stroke(color(50, 50, 50, 50));")
            printLine("tube.strokeWeight(1);")
            printLine("tube.fill(color(200, 200, 200, 50));")
            printLine("")
            printLine("Cylinder cylinder = new Cylinder(tube, mat);")
            printLine("cylinders.add(cylinder);")
        }
    }
    
    func printDrawCylinders() {
        indentedBlock("void drawCylinders() {") {
            indentedBlock("for (Cylinder cyl: cylinders) {") {
                printLine("pushMatrix();")
                indentedBlock("if (cyl.matrix != null) {") {
                    printLine("applyMatrix(cyl.matrix);")
                }
                printLine("")
                printLine("cyl.tube.draw(getGraphics());")
                printLine("popMatrix();")
            }
        }
    }
    
    func printDrawGrid2D() {
        indentedBlock("void drawGrid() {") {
            printLine("stroke(0, 0, 0, 30);")
            printLine("line(0, -20, 0, 20);")
            printLine("line(-20, 0, 20, 0);")
            indentedBlock("for (int x = -10; x < 10; x++) {") {
                printLine("stroke(0, 0, 0, 20);")
                printLine("line(x, -20, x, 20);")
            }
            indentedBlock("for (int y = -10; y < 10; y++) {") {
                printLine("stroke(0, 0, 0, 20);")
                printLine("line(-20, y, 20, y);")
            }
        }
    }
    
    func printDrawOrigin3D() {
        indentedBlock("void drawOrigin() {") {
            let length: Double = 100.0
            
            let vx = Vector3D.unitX * length
            let vy = Vector3D.unitY * length
            let vz = Vector3D.unitZ * length
            
            printLine("// X axis")
            printLine("stroke(255, 0, 0, 50);")
            printLine("line(\(Self.vec3String(Vector3D.zero)), \(Self.vec3String(vx)));")
            printLine("// Y axis")
            printLine("stroke(0, 255, 0, 50);")
            printLine("line(\(Self.vec3String(Vector3D.zero)), \(Self.vec3String(vy)));")
            printLine("// Z axis")
            printLine("stroke(0, 0, 255, 50);")
            printLine("line(\(Self.vec3String(Vector3D.zero)), \(Self.vec3String(vz)));")
        }
    }
    
    func printDrawNormal2D() {
        indentedBlock("void drawNormal(float x, float y, float nx, float ny) {") {
            printLine("float x2 = x + nx;")
            printLine("float y2 = y + ny;")
            printLine("")
            printLine("line(x, y, x2, y2);")
        }
    }
    
    func printDrawNormal3D() {
        indentedBlock("void drawNormal(float x, float y, float z, float nx, float ny, float nz) {") {
            printLine("float s = 10.0;")
            printLine("")
            printLine("float x2 = x + nx * s;")
            printLine("float y2 = y + ny * s;")
            printLine("float z2 = z + nz * s;")
            printLine("")
            printLine("strokeWeight(5 / scale);")
            printLine("stroke(255, 0, 0, 200);")
            printLine("line(x, y, z, x2, y2, z2);")
        }
    }
    
    func printDrawTangent2D() {
        indentedBlock("void drawTangent(float x, float y, float nx, float ny) {") {
            printLine("float s = 5.0;")
            printLine("")
            printLine("float x1 = x - ny * s;")
            printLine("float y1 = y + nx * s;")
            printLine("")
            printLine("float x2 = x + ny * s;")
            printLine("float y2 = y - nx * s;")
            printLine("")
            printLine("line(x1, y1, x2, y2);")
        }
    }
    
    func printDrawSphere() {
        indentedBlock("void drawSphere(float x, float y, float z, float radius) {") {
            boilerplate3DSpaceBar(lineWeight: 1.0).forEach(printLine)
            
            printLine("pushMatrix();")
            printLine("translate(x, y, z);")
            printLine("sphere(radius);")
            printLine("popMatrix();")
        }
    }

    func printDrawDisk() {
        indentedBlock("void drawDisk(float x, float y, float z, float radius, float nx, float ny, float nz) {") {
            printLine("int resolution = 20;")
            printLine("")

            printLine("PVector center = new PVector(x, y, z);")
            printLine("PVector normal = new PVector(nx, ny, nz);")
            printLine("normal.normalize();")
            printLine("")

            printLine("PVector rightVec;")
            printLine("")

            indentedBlock("if (normal.z != 1) {") {
                printLine("rightVec = normal.cross(new PVector(0, 0, 1));")
            }
            printLine("else")
            indentedBlock("{") {
                printLine("rightVec = normal.cross(new PVector(1, 0, 0));")
            }
            printLine("")

            printLine("PVector upVec = rightVec.cross(normal);")
            printLine("")

            boilerplate3DSpaceBar(lineWeight: 1.0).forEach(printLine)
            printLine("")

            printLine("pushMatrix();")
            printLine("")

            printLine("beginShape(TRIANGLE_FAN);")
            printLine("")

            printLine("vertex(center.x, center.y, center.z);")
            printLine("")
            
            indentedBlock("for (int i = 0; i <= resolution; i++) {") {
                printLine("float angle = PI * 2 * ((float)i) / ((float)resolution);")
                printLine("float dx = cos(angle) * radius;")
                printLine("float dy = sin(angle) * radius;")
                printLine("")

                printLine("PVector vec = center.copy();")
                printLine("vec.add(upVec.copy().mult(dx));")
                printLine("vec.add(rightVec.copy().mult(dy));")
                printLine("")

                printLine("vertex(vec.x, vec.y, vec.z);")
            }

            printLine("")
            printLine("endShape();")

            printLine("")
            printLine("popMatrix();")
        }
    }
    
    func printCylinderClass() {
        indentedBlock("class Cylinder {") {
            printLine("Tube tube;")
            printLine("PMatrix matrix;")
            printLine("")
            indentedBlock("Cylinder(Tube tube) {") {
                printLine("this.tube = tube;")
                printLine("this.matrix = null;")
            }
            printLine("")
            indentedBlock("Cylinder(Tube tube, float[] mat) {") {
                printLine("this.tube = tube;")
                printLine("")
                indentedBlock("if (mat != null) {") {
                    indentedBlock("this.matrix = new PMatrix3D(", closingBrace: ");") {
                        printLine("mat[0], mat[1], mat[2], mat[3],")
                        printLine("mat[4], mat[5], mat[6], mat[7],")
                        printLine("mat[8], mat[9], mat[10], mat[11],")
                        printLine("mat[12], mat[13], mat[14], mat[15]")
                    }
                }
            }
            printLine("")
            indentedBlock("Cylinder(Tube tube, PMatrix matrix) {") {
                printLine("this.tube = tube;")
                printLine("this.matrix = matrix;")
            }
        }
    }
    
    // MARK: - String printing
    
    static func vec3PVectorString<V: Vector3Type>(_ vec: V) -> String {
        "new PVector(\(vec3String(vec)))"
    }
    
    static func vec3String<V: Vector3Type>(_ vec: V) -> String {
        "\(vec.x), \(vec.y), \(vec.z)"
    }
    
    static func vec3String_pCoordinates<V: Vector3Type & VectorSigned>(_ vec: V) -> String {
        // Flip Y-Z axis (in Processing positive Y axis is down and positive Z axis is towards the screen)
        "\(vec.x), \(-vec.z), \(-vec.y)"
    }
    
    static func vec2String<V: Vector2Type>(_ vec: V) -> String {
        "\(vec.x), \(vec.y)"
    }
    
    static func vec2String_int<V: Vector2Type>(_ vec: V) -> String where V.Scalar: BinaryFloatingPoint {
        "\(Int(vec.x)), \(Int(vec.y))"
    }

    static func ellipse2String<V: Vector2Type>(_ ellipse: Ellipsoid<V>) -> String {
        "ellipse(\(vec2String(ellipse.center)), \(vec2String(ellipse.radius)));"
    }

    static func circle2String<V: Vector2Type>(_ circle: Circle2<V>) -> String {
        "circle(\(vec2String(circle.center)), \(circle.radius));"
    }

    static func sphere3String<V: Vector3Type>(_ sphere: Sphere3<V>) -> String {
        "drawSphere(\(vec3String(sphere.center)), \(sphere.radius));"
    }

    static func disk3String<V: Vector3Type>(_ disk: Disk3<V>) -> String {
        "drawDisk(\(vec3String(disk.center)), \(disk.radius), \(vec3String(disk.normal)));"
    }

    static func aabb2String<V: Vector2Additive & VectorDivisible>(_ aabb: AABB2<V>) -> String {
        "rect(\(vec2String(aabb.minimum)), \(vec2String(aabb.maximum)));"
    }

    static func line2String<Line: Line2Type>(_ line: Line) -> String {
        "line(\(vec2String(line.a)), \(vec2String(line.b)));"
    }

    static func line3String<Line: Line3Type>(_ line: Line) -> String {
        "line(\(vec3String(line.a)), \(vec3String(line.b)));"
    }

    static func ray3String<Vector: Vector3Type>(_ ray: DirectionalRay3<Vector>) -> String {
        "line(\(vec3String(ray.start)), \(vec3String(ray.projectedMagnitude(500))));"
    }

    static func pointNormal2String_normal<V: Vector2Type>(_ pointNormal: PointNormal<V>) -> String {
        "drawNormal(\(vec2String(pointNormal.point)), \(vec2String(pointNormal.normal)));"
    }

    static func pointNormal2String_tangent<V: Vector2Type>(_ pointNormal: PointNormal<V>) -> String {
        "drawTangent(\(vec2String(pointNormal.point)), \(vec2String(pointNormal.normal)));"
    }

    static func pointNormal3String_normal<V: Vector3Type>(_ pointNormal: PointNormal<V>) -> String {
        "drawNormal(\(vec3String(pointNormal.point)), \(vec3String(pointNormal.normal)));"
    }
    
    func mat2PMatrixString(_ matrix: RMatrix4x4, multiline: Bool = false) -> String {
        let prefix = "new PMatrix3D("
        let postfix = ")"
        
        var result = prefix
        
        if multiline {
            result += "\n\(indentString())"
        }
        
        result += mat2String(matrix, multiline: multiline)
        result += postfix
        
        return result
    }
    
    func mat2ArrayString<M: MatrixType>(_ matrix: M, multiline: Bool = false) -> String {
        "new float[] { \(mat2String(matrix, multiline: multiline)) }"
    }
    
    func mat2String<M: MatrixType>(_ matrix: M, multiline: Bool = false) -> String {
        var result = ""
        
        let values = matrix.rowMajorValues()
        
        if multiline {
            for row in 0..<matrix.rowCount {
                let start = row * matrix.columnCount
                let end = start + matrix.columnCount
                
                var line: String = indentString()
                line += Self.commaSeparated(values[start..<end], trailing: end != values.count)
                result += line + "\n"
            }
        } else {
            result = Self.commaSeparated(values)
        }
        
        return result
    }
    
    static func array2String<S: Sequence>(_ seq: S, typeName: String) -> String {
        let elements = commaSeparated(seq)
        
        return "new \(typeName)[] { \(elements)\(elements.isEmpty ? "" : " ")}"
    }
    
    static func commaSeparated<S: Sequence>(_ els: S, trailing: Bool = false) -> String {
        let list = els.map { "\($0)" }.joined(separator: ", ")
        if trailing {
            return list + ", "
        }
        
        return list
    }
    
    func printLine(_ line: String) {
        print("\(indentString())\(line)", to: &buffer)
    }
    
    private func printBuffer(target: ProcessingPrinterTarget) {
        target.printBuffer(buffer)

        buffer = ""
    }
    
    func indentString() -> String {
        indentString(depth: identDepth * currentIndent)
    }
    
    func indentString(depth: Int) -> String {
        String(repeating: " ", count: depth)
    }
    
    func indentedBlock(_ start: String, closingBrace: String = "}", _ block: () -> Void) {
        printLine(start)
        indented {
            block()
        }
        printLine(closingBrace)
    }
    
    func indented(_ block: () -> Void) {
        indent()
        block()
        deindent()
    }
    
    func indent() {
        currentIndent += 1
    }
    
    func deindent() {
        currentIndent -= 1
    }
}

extension ProcessingPrinter {
    static func withPrinter(_ block: (ProcessingPrinter) -> Void) {
        let printer = ProcessingPrinter(size: .init(x: 500, y: 500), scale: 25.0)
        
        block(printer)
        
        printer.printAll()
    }
}
