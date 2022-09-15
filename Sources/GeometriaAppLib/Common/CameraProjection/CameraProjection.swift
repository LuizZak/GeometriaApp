import ImagineUI
#if canImport(Geometria)
import Geometria
#endif

/// Allows projection of some 3D geometry into the camera of a scene, converting
/// the coordinates into pixel-coordinates to perform rasterization of the
/// geometry on screen.
public struct CameraProjection {
    let camera: Camera
    
    init(camera: Camera) {
        self.camera = camera
    }
    
    /// Attempts to project a given 3D line into screen coordinates as a `UILine`.
    ///
    /// Result is an unclamped 2D line that approximates the original 3D line
    /// as a projection on the camera.
    func projectLine(_ line: RLineSegment3D) -> UILine? {
        guard let start = camera.projectAsPixelUnclamped(line.start) else {
            return nil
        }
        guard let end = camera.projectAsPixelUnclamped(line.end) else {
            return nil
        }
        
        return UILine(start: UIPoint(start), end: UIPoint(end))
    }
    
    // TODO: Support spheres that partially clip into the camera plane.
    /// Attempts to project a 3D sphere into the screen coordinates as a `UICircle`.
    func projectSphere(_ sphere: RSphere3D) -> UICircle? {
        guard let projectedCenter = camera.projectAsPixelUnclamped(sphere.center) else {
            return nil
        }
        
        // Find an orthogonal axis to place a point on the outer edges of the
        // sphere relative to the camera to produce a point that is used to
        // calculate the on-screen radius of the sphere.
        // TODO: Find a more optimal way to compute the projected circle's radius
        let radiusAxis = (sphere.center - camera.cameraPlane.point).normalized().cross(camera.cameraPlane.upAxis)
        let radiusPoint = sphere.center + radiusAxis * sphere.radius
        
        guard let projectedRadius = camera.projectAsPixelUnclamped(radiusPoint) else {
            return nil
        }
        
        let radius = Double(projectedCenter.distanceSquared(to: projectedRadius)).squareRoot()
        
        return UICircle(
            center: UIPoint(projectedCenter),
            radius: radius
        )
    }
    
    /// Projects an AABB as a series of `UILine`s representing each edge of the
    /// AABB as it appears when projected on screen.
    func projectAABB<R: RectangleType>(_ aabb: R) -> [UILine] where R.Vector == RVector3D {
        var result: [UILine] = []
        
        func addEdgeLine(endPoint: RVector3D, axis: RVector3D) {
            let start = aabb.location + endPoint * aabb.size
            let end = start + axis * aabb.size
            
            let line = RLineSegment3D(start: start, end: end)
            
            if let projected = projectLine(line) {
                result.append(projected)
            }
        }
        
        // From AABB's top-left-back
        addEdgeLine(endPoint: .zero, axis: .unitX)
        addEdgeLine(endPoint: .zero, axis: .unitY)
        addEdgeLine(endPoint: .zero, axis: .unitZ)
        
        // From AABB's bottom-right-front
        addEdgeLine(endPoint: .one, axis: -.unitX)
        addEdgeLine(endPoint: .one, axis: -.unitY)
        addEdgeLine(endPoint: .one, axis: -.unitZ)
        
        // Fill in remaining six lines required
        addEdgeLine(endPoint: .unitX, axis: .unitY)
        addEdgeLine(endPoint: .unitX, axis: .unitZ)
        
        addEdgeLine(endPoint: .unitZ, axis: .unitX)
        addEdgeLine(endPoint: .unitZ, axis: .unitY)
        
        addEdgeLine(endPoint: .unitY, axis: .unitX)
        addEdgeLine(endPoint: .unitY, axis: .unitZ)
        
        return result
    }
}
