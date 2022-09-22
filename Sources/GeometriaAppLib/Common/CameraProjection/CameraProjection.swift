import ImagineUI
#if canImport(Geometria)
import Geometria
#endif

/// Allows projection of some 3D geometry into the camera of a scene, converting
/// the coordinates into pixel-coordinates to perform rasterization of the
/// geometry on screen.
public class CameraProjection {
    let camera: Camera
    
    init(camera: Camera) {
        self.camera = camera
    }
    
    /// Attempts to project a given 3D line into screen coordinates as a
    /// `RenderingShape`.
    ///
    /// Result is an unclamped 2D line that approximates the original 3D line
    /// as a projection on the camera.
    func projectLine(_ line: RLineSegment3D) -> RenderingShape? {
        guard let start = camera.projectAsPixelUnclamped(line.start) else {
            return nil
        }
        guard let end = camera.projectAsPixelUnclamped(line.end) else {
            return nil
        }
        
        return .line(UILine(start: UIPoint(start), end: UIPoint(end)))
    }
    
    // TODO: Support spheres that partially clip into the camera plane.
    /// Attempts to project a 3D sphere into the screen coordinates as a
    /// `RenderingShape`.
    func projectSphere(_ sphere: RSphere3D) -> RenderingShape? {
        guard let projectedCenter = projectPoint(sphere.center) else {
            return nil
        }
        
        // Find an orthogonal axis to place a point on the outer edges of the
        // sphere relative to the camera to produce points that are used to
        // calculate the on-screen radius of the sphere.
        // TODO: Find a more optimal way to compute the projected circle's radius
        let cameraDirection = (sphere.center - camera.cameraPlane.point).normalized()

        let radiusVAxis = cameraDirection.cross(camera.cameraPlane.rightAxis)
        let radiusHAxis = cameraDirection.cross(camera.cameraPlane.upAxis)

        let radiusVPoint = sphere.project(sphere.center + radiusVAxis)
        let radiusHPoint = sphere.project(sphere.center + radiusHAxis)
        
        guard
            let projectedV = projectPoint(radiusVPoint),
            let projectedH = projectPoint(radiusHPoint)
        else {
            return nil
        }
        
        let radius = UIVector(
            x: projectedCenter.distance(to: projectedH),
            y: projectedCenter.distance(to: projectedV)
        )
        
        return .ellipse(
            UIEllipse(
                center: UIPoint(projectedCenter),
                radius: radius
            )
        )
    }
    
    /// Projects an AABB as a `RenderingShape` representing each edge of the AABB
    /// as it appears when projected on screen.
    func projectAABB<R: RectangleType>(_ aabb: R) -> RenderingShape where R.Vector == RVector3D {
        var result: [RenderingShape] = []
        
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
        
        return .shapes(result)
    }
    
    private var _lastDisk: RDisk3D?
    /// Attempts to project a 3D disk into the screen coordinates as a
    /// `RenderingShape`.
    func projectDisk(_ disk: RDisk3D) -> RenderingShape? {
        let processing: ProcessingPrinter?
        if _lastDisk == disk {
            _lastDisk = disk
            processing =
                RaytracerProcessingPrinter(
                    viewportSize: camera.viewportSize,
                    scene: nil,
                    sceneCamera: camera
                )
        } else {
            processing = nil
        }

        guard let projectedCenter = projectPoint(disk.center) else {
            return nil
        }

        let cameraDirection = camera.cameraPlane.normal

        let radiusVAxis = cameraDirection.cross(disk.normal).normalized()
        let radiusHAxis = disk.normal.cross(radiusVAxis).normalized()

        let radiusHPoint = (disk.center + radiusHAxis * disk.radius)
        let radiusVPoint = (disk.center + radiusVAxis * disk.radius)

        processing?.add(disk: disk)
        processing?.add(line:
            RLineSegment3D(
                start: camera.cameraCenterPoint,
                end: disk.center
            )
        )
        processing?.add(line:
            RLineSegment3D(
                start: disk.center,
                end: radiusHPoint
            )
        )
        processing?.add(line:
            RLineSegment3D(
                start: disk.center,
                end: radiusVPoint
            )
        )
        processing?.printAll()
        
        guard
            let projectedV = projectPoint(radiusVPoint),
            let projectedH = projectPoint(radiusHPoint)
        else {
            return nil
        }

        let radius = UIVector(
            x: projectedCenter.distance(to: projectedH),
            y: projectedCenter.distance(to: projectedV)
        )

        // TODO: Apply transform to rotate disk depending on screen orientation.

        return .ellipse(
            UIEllipse(
                center: UIPoint(projectedCenter),
                radius: radius
            )
        )
    }

    private func projectPoint(_ vec: RVector3D) -> PixelCoord? {
        camera.projectAsPixelUnclamped(vec)
    }

    enum RenderingShape {
        case ellipse(UIEllipse)
        case line(UILine)

        indirect case shapes([Self])
        indirect case transform(transform: UIMatrix, shape: Self)

        /// Returns `true` if the contents of this rendering shape are empty and
        /// would not produce draw calls.
        var isEmpty: Bool {
            switch self {
            case .ellipse, .line:
                return false
            case .shapes(let list):
                return list.isEmpty || list.allSatisfy(\.isEmpty)
            case .transform(_, let shape):
                return shape.isEmpty
            }
        }
    }
}
