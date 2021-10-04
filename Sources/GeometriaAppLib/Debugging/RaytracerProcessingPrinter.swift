class RaytracerProcessingPrinter: ProcessingPrinter {
    var sceneCamera: Camera?

    init(viewportSize: RVector2D, sceneCamera: Camera? = nil) {
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
        add(intersection: hit.intersection)
        addDrawLine("")
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
        
        printLine("cam = new PeasyCam(this, \(vec3String_pCoordinates(camera.cameraPlane.point)), \(-camera.cameraCenterOffset));")
        printLine("cam.setWheelScale(0.3);")
        printLine("cam.rotateX(\(elevation));")
    }
}

extension RaytracerProcessingPrinter {
    static func withRaytracerPrinter(viewportSize: ViewportSize, _ block: (RaytracerProcessingPrinter) -> Void) {
        let printer = RaytracerProcessingPrinter(viewportSize: RVector2D(viewportSize))
        
        block(printer)
        
        printer.printAll()
    }
}
