import Geometria

struct Camera {
    var cameraPlane: ProjectivePointNormalPlane3<RVector3D> =
        .makeCorrectedPlane(point: RVector3D.unitZ * 5,
                            normal: .init(x: 0, y: 5, z: -1),
                            upAxis: .unitZ)
    
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
    
    var cameraCenterPoint: RVector3D = .zero
    var cameraSizeInWorld: RVector2D = RVector2D(x: 400, y: 300)
    var cameraDownsize: Double = 0.3
    var cameraSizeScale: Double = 0.1
    
    var viewportSize: PixelCoord {
        didSet {
            recomputeCamera()
        }
    }
    
    init(viewportSize: PixelCoord) {
        self.viewportSize = viewportSize
        
        recomputeCamera()
    }
    
    mutating func recomputeCamera() {
        cameraSizeScale = (cameraSizeInWorld / RVector2D(viewportSize)).maximalComponent * cameraDownsize
        cameraPlane.point.z = Double(viewportSize.y) * cameraSizeScale + cameraZOffset
        cameraCenterPoint = cameraPlane.point + cameraPlane.normal * cameraCenterOffset
    }
    
    func rayFromCamera(at point: PixelCoord) -> RRay3D {
        let centeredPoint = (point - viewportSize / 2) * PixelCoord(x: 1, y: -1)
        let projectedPoint = RVector2D(centeredPoint) * cameraSizeScale
        
        let inWorld = cameraPlane.projectOut(projectedPoint)
        let dir = inWorld - cameraCenterPoint
        
        return RRay3D(start: inWorld, direction: dir)
    }
}
