class RaytracerProcessingPrinter: ProcessingPrinter {
    private var _elementsVisible: Set<Int> = []
    
    var scene: SceneType
    var sceneCamera: Camera?
    
    init(viewportSize: RVector2D, scene: SceneType, sceneCamera: Camera? = nil) {
        self.scene = scene
        self.sceneCamera = sceneCamera
        super.init(size: viewportSize, scale: 1.5)
    }
    
    func addRaycast(
        hit: RayHit,
        ray: DirectionalRay3<RVector3D>,
        function: String = #function,
        lineNumber: Int = #line
    ) {
        let lineSegment = RLineSegment3D(start: ray.start, end: hit.point)

        add(line: lineSegment, comment: "\(function):\(lineNumber) (direction: \(ray.direction))")
        add(hit: hit, function: function, lineNumber: lineNumber)
    }
    
    func addRaycast(
        ray: DirectionalRay3<RVector3D>,
        function: String = #function,
        lineNumber: Int = #line
    ) {
        add(ray: ray, comment: "\(function):\(lineNumber) (direction: \(ray.direction))")
    }
    
    func add(hit: RayHit, function: String = #function, lineNumber: Int = #line) {
        is3D = true
        
        addDrawLine("// \(function):\(lineNumber)")
        addStrokeColorSet("255, 0, 0")
        addStrokeWeightSet("2 / scale")
        add(pointNormal: hit.pointNormal)
        add(id: hit.id)
        addDrawLine("")
    }
    
    func add(id: Int) {
        if !_elementsVisible.insert(id).inserted {
            return
        }
        
        let finder = ProcessingSceneElementProvider(scene: scene)
        guard let element = finder.findElement(id: id) else {
            return
        }
        
        let kind = element.element
        let transform = element.transform
        
        switch kind {
        case .sphere(let element):
            add(sphere: element, comment: "id: \(id)", transform: transform)
            
        case .aabb(let element):
            add(aabb: element, comment: "id: \(id)", transform: transform)
            
        case .cylinder(let element):
            add(cylinder: element, comment: "id: \(id)", transform: transform)
            
        case .ellipse(let element):
            add(ellipse3: element, comment: "id: \(id)", transform: transform)
            
        case .disk(let element):
            add(disk: element, comment: "id: \(id)", transform: transform)
            
        case .lineSegment(let element):
            add(line: element)
            
        case .plane(let element):
            // TODO
            _ = element
            
        case .torus(let element):
            // TODO
            _ = element
            
        case .hyperplane(let element):
            // TODO
            _ = element
        }
    }
    
    // MARK: Custom printing code
    
    /// Prepares geometry added to `addedGeometry` before it's print out by
    /// `printDraw`.
    override func prepareCustomPreFile() {
        
    }
    
    override func printCustomPostSetup() {
        guard let camera = sceneCamera else {
            return
        }
        
        
        let elevation = -camera.cameraPlane.normal.elevation
        
        printLine("cam = new PeasyCam(this, \(Self.vec3String_pCoordinates(camera.cameraPlane.point)), \(90));")
        printLine("cam.setWheelScale(0.3);")
        printLine("cam.rotateX(\(elevation));")
    }
}

extension RaytracerProcessingPrinter {
    static func withRaytracerPrinter(
        viewportSize: ViewportSize,
        scene: SceneType,
        _ block: (RaytracerProcessingPrinter) -> Void
    ) {
        
        let printer = RaytracerProcessingPrinter(
            viewportSize: RVector2D(viewportSize),
            scene: scene
        )
        
        block(printer)
        
        printer.printAll()
    }
}
