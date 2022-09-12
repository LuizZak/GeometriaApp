class RaytracerProcessingPrinter: ProcessingPrinter {
    private var _elementsVisible: Set<Int> = []
    
    var scene: SceneType
    var sceneCamera: Camera?

    init(viewportSize: RVector2D, scene: SceneType, sceneCamera: Camera? = nil) {
        self.scene = scene
        self.sceneCamera = sceneCamera
        super.init(size: viewportSize, scale: 1.5)
    }
    
    func add(hit: RayHit, ray: DirectionalRay3<RVector3D>) {
        is3D = true
        
        let line = LineSegment3<RVector3D>(start: ray.start, end: hit.point)
        
        add(line: line, color: "255, 0, 0")
        add(hit: hit)
    }
    
    func add(hit: RayHit) {
        is3D = true
        
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
            add(sphere: element, transform: transform)
            
        case .aabb(let element):
            add(aabb: element, transform: transform)
            
        case .cylinder(let element):
            add(cylinder: element, transform: transform)
            
        case .ellipse(let element):
            add(ellipse3: element, transform: transform)
            
        case .disk(let element):
            // TODO
            _ = element
            
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
        
        printLine("cam = new PeasyCam(this, \(vec3String_pCoordinates(camera.cameraPlane.point)), \(90));")
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
