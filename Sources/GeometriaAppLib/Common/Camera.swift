import ImagineUI

struct Camera {
    var cameraPlane: ProjectivePointNormalPlane3<RVector3D> =
        .makeCorrectedPlane(
            point: RVector3D.unitZ * 5,
            normal: .init(x: 0, y: 5, z: -1),
            upAxis: .unitZ
        )

    var projectionMode: ProjectionMode = .perspective(cameraCenterOffset: -90) {
        didSet {
            recomputeCamera()
        }
    }
    
    var cameraZOffset: Double = 0.0 {
        didSet {
            recomputeCamera()
        }
    }
    
    var cameraSizeInWorld: RVector2D = RVector2D(x: 400, y: 300)
    var cameraDownsize: Double = 0.3
    var cameraSizeScale: Double = 0.1
    
    var viewportSize: ViewportSize {
        didSet {
            recomputeCamera()
        }
    }
    
    init(viewportSize: ViewportSize) {
        self.viewportSize = viewportSize
        
        recomputeCamera()
    }
    
    mutating func recomputeCamera() {
        cameraSizeScale = (cameraSizeInWorld / RVector2D(viewportSize)).maximalComponent * cameraDownsize
        cameraPlane.point.z = Double(viewportSize.height) * cameraSizeScale + cameraZOffset
    }
    
    func rayFromCamera(at point: PixelCoord) -> RRay3D {
        let centeredPoint = (point - viewportSize / 2) * PixelCoord(x: 1, y: -1)
        let projectedPoint = RVector2D(centeredPoint) * cameraSizeScale
        
        let inWorld = cameraPlane.projectOut(projectedPoint)

        let dir: RVector3D

        switch projectionMode {
        case .perspective(let cameraCenterOffset):
            let cameraCenterPoint = cameraPlane.point + cameraPlane.normal * cameraCenterOffset
            dir = inWorld - cameraCenterPoint
        
        case .orthographic:
            dir = cameraPlane.normal
        }
        
        return RRay3D(start: inWorld, direction: dir)
    }

    /// Specifies the projective mode of a camera
    enum ProjectionMode {
        /// A perspective camera, where the image is projected past the camera
        /// plane into a single center point located `cameraCenterOffset` units
        /// away from the camera plane's center.
        case perspective(cameraCenterOffset: Double)

        /// An orthographic camera where all rays are orthogonal to the plane
        /// of the camera.
        case orthographic
    }
}
