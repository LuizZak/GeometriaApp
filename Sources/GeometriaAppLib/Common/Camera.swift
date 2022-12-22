import ImagineUI
#if canImport(Geometria)
import Geometria
#endif

public struct Camera {
    private var _cameraDownsize: Double = 0.3
    private var _cameraSizeScale: Double

    public var cameraPlane: ProjectivePointNormalPlane3<RVector3D> =
        .makeCorrectedPlane(
            point: RVector3D.unitZ * 5,
            normal: .init(x: 0, y: 5, z: -1),
            upAxis: .unitZ
        )

    public var projectionMode: ProjectionMode {
        didSet {
            recomputeCamera()
        }
    }
    
    public var cameraSizeInWorld: RVector2D = RVector2D(x: 400, y: 300)

    /// Gets the center point of the camera for projective operations.
    public var cameraCenterPoint: RVector3D {
        switch projectionMode {
        case .perspective(let focalLength):
            return cameraPlane.point - cameraPlane.normal * focalLength

        case .orthographic:
            return cameraPlane.point
        }
    }
    
    public var viewportSize: ViewportSize {
        didSet {
            recomputeCamera()
        }
    }
    
    public init(
        viewportSize: ViewportSize,
        viewportCenter: RVector3D,
        projectionMode: ProjectionMode = .perspective(focalLength: 90)
    ) {

        self.viewportSize = viewportSize
        self.projectionMode = projectionMode
        self.cameraPlane.point = viewportCenter

        _cameraSizeScale = 1.0
        
        recomputeCamera()
    }
    
    mutating func recomputeCamera() {
        _cameraSizeScale = (cameraSizeInWorld / RVector2D(viewportSize)).maximalComponent * _cameraDownsize
    }
    
    public func rayFromCamera(at point: PixelCoord) -> RRay3D {
        let inWorld = pixelToWorld(point)

        let dir: RVector3D
        switch projectionMode {
        case .perspective(let focalLength):
            let cameraCenterPoint = cameraPlane.point - cameraPlane.normal * focalLength
            dir = inWorld - cameraCenterPoint
        
        case .orthographic:
            dir = cameraPlane.normal
        }
        
        return RRay3D(start: inWorld, direction: dir)
    }

    /// Converts a given pixel coordinate to a world coordinate based on the
    /// camera plane's position and orientation.
    public func pixelToWorld(_ point: PixelCoord) -> RVector3D {
        let projectedPoint = pixelToPlane(point: point)

        return cameraPlane.projectOut(projectedPoint)
    }
    
    /// Projects a 3D point into the camera's plane.
    ///
    /// Ignores points that are not contained within the camera's frustum.
    public func projectToCamera(_ point: RVector3D) -> RVector2D? {
        if cameraPlane.signedDistance(to: point) < 0 {
            return nil
        }
        
        guard let pointOnPlane = projectToCameraUnclamped(point) else {
            return nil
        }
        
        var minPixel = pixelToPlane(point: .zero)
        var maxPixel = pixelToPlane(point: viewportSize.asUIIntPoint)
        
        (minPixel, maxPixel) = (min(minPixel, maxPixel), max(minPixel, maxPixel))
        
        guard pointOnPlane >= minPixel && pointOnPlane <= maxPixel else {
            return nil
        }
        
        return pointOnPlane
    }
    
    /// Projects a 3D point into the camera's plane.
    ///
    /// Includes points that are outside the frustum of the camera.
    public func projectToCameraUnclamped(_ point: RVector3D) -> RVector2D? {
        let pointOnPlane: RVector2D?
        
        switch projectionMode {
        case .perspective(let focalLength):
            let cameraCenterPoint = cameraPlane.point - cameraPlane.normal * focalLength
            
            // TODO: Implement proper plane perspective projection in Geometria
            // to use here instead of this explicit line-intersection construction
            let line = RLine3D(a: point, b: cameraCenterPoint)
            
            pointOnPlane = cameraPlane.projectLineIntersection(line)
            
        case .orthographic:
            pointOnPlane = cameraPlane.project2D(point)
        }
        
        return pointOnPlane
    }
    
    /// Projects a 3D point into the camera's plane, returning the equivalent
    /// pixel coordinates of the projection's result.
    ///
    /// Includes points that are outside the frustum of the camera.
    public func projectAsPixelUnclamped(_ point: RVector3D) -> PixelCoord? {
        guard let projected = projectToCameraUnclamped(point) else {
            return nil
        }
        
        return planeToPixel(point: projected)
    }
    
    /// Converts an integer pixel screen-coordinate into a projected 2D value on
    /// the camera plane.
    public func pixelToPlane(point: PixelCoord) -> RVector2D {
        let vecPoint = RVector2D(point)
        
        let centeredPoint = (vecPoint - RVector2D(viewportSize) / 2) * RVector2D(x: 1, y: -1)
        let projectedPoint = centeredPoint * _cameraSizeScale
        
        return projectedPoint
    }
    
    /// Converts a projected 2D coordinate from the camera plane into an integer
    /// pixel screen-coordinate.
    public func planeToPixel(point: RVector2D) -> PixelCoord {
        let scaledPoint = point / _cameraSizeScale
        let decenteredPoint = (scaledPoint * RVector2D(x: 1, y: -1)) + RVector2D(viewportSize) / 2
        
        return PixelCoord(x: Int(decenteredPoint.x), y: Int(decenteredPoint.y))
    }

    /// Specifies the projective mode of a camera
    public enum ProjectionMode {
        /// A perspective camera, where the image is projected past the camera
        /// plane into a single center point located `focalLength` units away
        /// from the camera plane's center.
        case perspective(focalLength: Double)

        /// An orthographic camera where all rays are orthogonal to the plane
        /// of the camera.
        case orthographic
    }
}
