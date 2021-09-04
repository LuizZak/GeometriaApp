import Geometria

struct Camera {
    var cameraPlane: Plane = Plane(point: .unitZ * 5, normal: .init(x: 0, y: 5, z: -1))
    
    var cameraCenterOffset: Double = -90.0 {
        didSet {
            recomputeCamera()
        }
    }
    
    var cameraZOffset: Double = 0.0 {
        didSet {
            recomputeCamera()
        }
    }
    
    var cameraCenterPoint: Vector3D = .zero
    var cameraSizeInWorld: Vector = Vector(x: 400, y: 300)
    var cameraDownsize: Double = 0.3
    var cameraSizeScale: Double = 0.1
    
    var cameraSize: Vector
    
    init(cameraSize: Vector) {
        self.cameraSize = cameraSize
        
        recomputeCamera()
    }
    
    mutating func recomputeCamera() {
        cameraSizeScale = (cameraSizeInWorld / cameraSize).maximalComponent * cameraDownsize
        cameraPlane.point.z = cameraSize.y * cameraSizeScale + cameraZOffset
        cameraCenterPoint = cameraPlane.point + cameraPlane.normal * cameraCenterOffset
    }
    
    func rayFromCamera(at point: Vector2i) -> Ray {
        var cameraXY = Vector(point)
        cameraXY -= cameraSize / 2
        cameraXY *= cameraSizeScale
        cameraXY *= Vector(x: 1, y: -1)
        var cameraXZ = Vector3D(x: cameraXY.x, y: 0, z: cameraXY.y)
        cameraXZ += cameraPlane.point
        
        let dir = cameraXZ - cameraCenterPoint
        
        return Ray(start: cameraXZ, direction: dir)
    }
}
