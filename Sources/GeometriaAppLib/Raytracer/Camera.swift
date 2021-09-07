import Geometria

struct Camera {
    private var cameraPlane: ProjectivePointNormalPlane3<Vector3D> =
        .makeCorrectedPlane(point: .unitZ * 5,
                            normal: .init(x: 0, y: 5, z: -1),
                            upAxis: .unitZ)
    
    private var cameraCenterOffset: Double = -90.0 {
        didSet {
            recomputeCamera()
        }
    }
    
    private var cameraZOffset: Double = 0.0 {
        didSet {
            recomputeCamera()
        }
    }
    
    private var cameraCenterPoint: Vector3D = .zero
    private var cameraSizeInWorld: Vector = Vector(x: 400, y: 300)
    private var cameraDownsize: Double = 0.3
    private var cameraSizeScale: Double = 0.1
    
    var viewportSize: Vector2i {
        didSet {
            recomputeCamera()
        }
    }
    
    init(viewportSize: Vector2i) {
        self.viewportSize = viewportSize
        
        recomputeCamera()
    }
    
    mutating func recomputeCamera() {
        cameraSizeScale = (cameraSizeInWorld / Vector(viewportSize)).maximalComponent * cameraDownsize
        cameraPlane.point.z = Double(viewportSize.y) * cameraSizeScale + cameraZOffset
        cameraCenterPoint = cameraPlane.point + cameraPlane.normal * cameraCenterOffset
    }
    
    func rayFromCamera(at point: Vector2i) -> Ray {
        let centeredPoint = (point - viewportSize / 2) * Vector2i(x: 1, y: -1)
        let projectedPoint = Vector(centeredPoint) * cameraSizeScale
        
        let inWorld = cameraPlane.projectOut(projectedPoint)
        let dir = inWorld - cameraCenterPoint
        
        return Ray(start: inWorld, direction: dir)
    }
}
