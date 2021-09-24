class RaytracerProcessingPrinter: ProcessingPrinter {
    var addedGeometry: [SceneGeometry] = []
    var sceneCamera: Camera?

    init(viewportSize: RVector2D, sceneCamera: Camera? = nil) {
        self.sceneCamera = sceneCamera
        super.init(size: viewportSize, scale: 1.5)
    }
    
    func add(geometry: SceneGeometry) {
        guard !addedGeometry.contains(where: { $0 === geometry }) else {
            return
        }
        
        addedGeometry.append(geometry)
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
        add(geometry: hit.sceneGeometry)
        add(intersection: hit.intersection)
        addDrawLine("")
    }
    
    // MARK: Custom printing code
    
    /// Prepares geometry added to `addedGeometry` before it's print out by
    /// `printDraw`.
    override func prepareCustomPreFile() {
        for geo in addedGeometry {
            switch geo.geometry {
            case let obj as RSphere3D:
                add(sphere: obj)
            case let ell as REllipse3D:
                add(ellipse3: ell)
            case let aabb as RAABB3D:
                add(aabb: aabb)
            case let cylinder as RCylinder3D:
                add(cylinder: cylinder)
            default:
                addDrawLine("// Unhandled geometric type: \(type(of: geo.geometry))")
            }
        }
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
