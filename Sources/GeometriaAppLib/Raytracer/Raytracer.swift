import SwiftBlend2D
import Geometria
import Foundation

class Raytracer {
    private var scene: Scene
    private let numThreads = 8
    private let batchSize = 100
    private var totalPixels: Int64 = 0
    
    @ConcurrentValue private var currentPixels: Int64 = 0
    
    var viewportSize: BLSizeI
    var buffer: RaytracerBufferWriter
    var hasWork: Bool = true
    
    /// The next coordinate the raytracer will fill.
    var coord: BLPointI
    
    /// Progress of rendering, from 0.0 to 1.0, inclusive.
    @ConcurrentValue var progress: Double = 0.0
    
    /// Inverts ordering of pixel fillig from X-Y to Y-X.
    var invertRender = true
    
    init(viewportSize: BLSizeI, buffer: RaytracerBufferWriter) {
        self.viewportSize = viewportSize
        self.buffer = buffer
        scene = Scene(cameraSize: .zero)
        coord = .zero
        createScene()
    }
    
    func initialize() {
        coord = .zero
        totalPixels = Int64(buffer.size.w) * Int64(buffer.size.h)
        currentPixels = 0
        progress = 0.0
        buffer.clearAll(color: .cornflowerBlue)
        createScene()
    }
    
    func createScene() {
        scene = Scene(cameraSize: .init(viewportSize))
    }
    
    func run(steps: Int) {
        guard hasWork else {
            return
        }
        
        var coords: [BLPointI] = []
        coords.reserveCapacity(steps)
        
        for _ in 0..<steps {
            coords.append(coord)
            
            if !incCoord() {
                hasWork = false
                break
            }
        }
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = numThreads
        
        batching(coords, by: batchSize) { batch in
            queue.addOperation {
                for coord in batch {
                    self.doRayCasting(at: coord)
                }
                
                self._currentPixels.modifyingValue { v in
                    v += Int64(batch.count)
                }
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
        
        progress = Double(currentPixels) / Double(totalPixels)
    }
    
    // MARK: Batching
    
    func batching<C: Collection>(_ array: C, by chunkSize: Int, _ closure: (C.SubSequence) -> Void) where C.Index == Int {
        for c in chunked(array, by: chunkSize) {
            closure(c)
        }
    }
    
    func chunked<C: Collection>(_ list: C, by chunkSize: Int) -> [C.SubSequence] where C.Index == Int {
        return stride(from: 0, to: list.count, by: chunkSize).map {
            list[$0..<min($0 + chunkSize, list.count)]
        }
    }
    
    // MARK: - Coordinate Management
    
    func incCoord() -> Bool {
        guard let next = nextCoord(from: coord) else {
            return false
        }
        
        coord = next
        
        return true
    }

    func nextCoord(from coord: BLPointI) -> BLPointI? {
        var coord = coord
        
        if invertRender {
            coord.y += 1
            if coord.y >= buffer.size.h {
                coord.y = 0
                coord.x += 1
            }
            
            if coord.x >= buffer.size.w {
                return nil
            }
        } else {
            coord.x += 1
            if coord.x >= buffer.size.w {
                coord.x = 0
                coord.y += 1
            }
            
            if coord.y >= buffer.size.h {
                return nil
            }
        }
        
        return coord
    }
    
    // MARK: - Ray Casting
    
    func doRayCasting(at coord: BLPointI) {
        let ray = scene.rayFromCamera(at: coord)
        guard let hit = scene.intersect(ray: ray) else {
            return
        }
        
        var color: BLRgba32 = .white
        
        if hit.geometry is Plane {
            let checkerSize = 50.0
            let checkerPhase = abs(hit.point) % checkerSize * 2
            
            var isWhite = false
            
            switch (checkerPhase.x, checkerPhase.y) {
            case (checkerSize..., checkerSize...), (0...checkerSize, 0...checkerSize):
                isWhite = false
            default:
                isWhite = true
            }
            
            if hit.point.x < 0 {
                isWhite.toggle()
            }
            if hit.point.y < 0 {
                isWhite.toggle()
            }
            
            color = isWhite ? .white : .black
        }
        
        // Shade
        let shade = max(0.0, min(0.4, hit.normal.dot(-ray.direction)))
        color = color.faded(towards: .black, factor: Float(1 - shade))
        
        // Shadow or sunlight
        let shadowRay = Ray(start: hit.point, direction: -scene.sunDirection)
        if scene.intersect(ray: shadowRay, ignoring: hit.geometry) != nil {
            // Shadow
            color = color.faded(towards: .black, factor: 0.5)
        } else {
            // Sunlight direction
            let sunDirDot = max(0.0, min(0.8, pow(hit.normal.dot(-scene.sunDirection), 5)))
            color = color.faded(towards: .white, factor: Float(sunDirDot))
        }
        
        
        let far = 1000.0
        let dist = ray.a.distanceSquared(to: hit.point)
        let distFactor = max(0, min(1, Float(dist / (far * far))))
        color = color.faded(towards: .cornflowerBlue, factor: distFactor)
        
        buffer.setPixel(at: coord, color: color)
    }
}

// MARK: - Scene

private extension Raytracer {
    struct Scene {
        var cameraPlane: Plane = Plane(point: .unitZ * 5, normal: .unitY) {
            didSet {
                recomputeCamera()
            }
        }
        
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
        var cameraSize: Vector
        var cameraSizeScale: Double = 0.3
        
        // MARK: - Scene
        
        // AABB
        var aabb: Geometria.AABB<Vector3D> = .init(minimum: .init(x: -20, y: 90, z: 80),
                                                   maximum: .init(x: 60, y: 100, z: 95))
        
        // Sphere
        var sphere: NSphere<Vector3D> = .init(center: .init(x: 0, y: 150, z: 45), radius: 30)
        
        // Floor plane
        var floorPlane: Plane = Plane(point: .zero, normal: .unitZ)
        
        /// Direction an infinitely far away point light is pointed at the scene
        @UnitVector var sunDirection: Vector3D = Vector3D(x: -20, y: 40, z: -30)
        
        // MARK: -
        
        init(cameraSize: Vector) {
            self.cameraSize = cameraSize
            cameraPlane.point.z = cameraSize.y * cameraSizeScale + cameraZOffset
            
            recomputeCamera()
        }
        
        func intersect(ray: Ray, ignoring: GeometricType? = nil) -> RayHit? {
            if ignoring as? Geometria.AABB<Vector3D> != aabb {
                if let hit = doRayCasting(ray: ray, convex: aabb) {
                    return hit
                }
            }
            
            if ignoring as? NSphere != sphere {
                if let hit = doRayCasting(ray: ray, convex: sphere) {
                    return hit
                }
            }
            
            if ignoring as? Plane != floorPlane {
                if let h = floorPlane.intersection(with: ray) {
                    return RayHit(point: h, normal: floorPlane.normal, geometry: floorPlane)
                }
            }
            
            return nil
        }
        
        func doRayCasting<C: ConvexType>(ray: Ray, convex: C) -> RayHit? where C.Vector == Vector3D {
            switch convex.intersection(with: ray) {
            case .enter(let pt),
                 .enterExit(let pt, _),
                 .singlePoint(let pt):
                
                return RayHit(point: pt.point, normal: pt.normal, geometry: convex)
            default:
                return nil
            }
        }
        
        mutating func recomputeCamera() {
            cameraCenterPoint = cameraPlane.point + cameraPlane.normal * cameraCenterOffset
        }
        
        func rayFromCamera(at point: BLPointI) -> Ray {
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
    
    struct RayHit {
        var point: Vector3D
        var normal: Vector3D
        var geometry: GeometricType
    }
}
