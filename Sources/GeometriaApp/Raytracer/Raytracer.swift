import SwiftBlend2D
import Geometria
import Foundation

class Raytracer {
    var viewportSize: BLSizeI
    var buffer: RaytracerBufferWriter
    var hasWork: Bool = true
    var coord: BLPointI
    /// Inverts ordering of pixel fillig from X-Y to Y-X.
    var invertRender = true
    private var scene: Scene
    
    init(viewportSize: BLSizeI, buffer: RaytracerBufferWriter) {
        self.viewportSize = viewportSize
        self.buffer = buffer
        scene = Scene(cameraSize: .zero)
        coord = .zero
        createScene()
    }
    
    func initialize() {
        coord = .zero
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
        
        for _ in 0..<steps {
            guard let next = nextCoord() else {
                break
            }
            
            coords.append(next)
            incCoord()
        }
        
        let numThreads = 8
        let batchSize = 100
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = numThreads
        
        batching(coords, by: batchSize) { batch in
            queue.addOperation {
                for coord in batch {
                    self.doRayCasting(at: coord)
                }
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
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
        
        // Sunlight direction
        let sunDir = Vector3D(x: -20, y: 40, z: -30).normalized()
        let sunDirDot = max(0.0, min(0.8, pow(hit.normal.dot(-sunDir), 5)))
        color = color.faded(towards: .white, factor: Float(sunDirDot))
        
        let far = 1000.0
        let dist = ray.a.distance(to: hit.point)
        let distFactor = max(0, min(1, Float(dist / far)))
        color = color.faded(towards: .cornflowerBlue, factor: distFactor)
        
        buffer.setPixel(at: coord, color: color)
    }
    
    func incCoord() {
        coord = nextCoord() ?? coord
    }

    func nextCoord() -> BLPointI? {
        var coord = self.coord
        
        if invertRender {
            coord.y += 1
            if coord.y >= buffer.size.h {
                coord.y = 0
                coord.x += 1
            }
            
            if coord.x >= buffer.size.w {
                coord = .zero
                hasWork = false
            }
        } else {
            coord.x += 1
            if coord.x >= buffer.size.w {
                coord.x = 0
                coord.y += 1
            }
            
            if coord.y >= buffer.size.h {
                coord = .zero
                hasWork = false
            }
        }
        
        return coord
    }
}

private extension Raytracer {
    struct Scene {
        var cameraPlane = Plane(point: .init(x: 0, y: 0, z: 5),
                                normal: .unitY)
        var cameraCenterOffset = -50.0
        var cameraZOffset = 0.0
        var floorPlane = Plane(point: .zero, normal: .unitZ)
        
        var sphere = NSphere<Vector3D>(center: .init(x: 0, y: 150, z: 45), radius: 30)
        
        var cameraSize: Vector
        var cameraSizeScale: Double = 0.3
        
        init(cameraSize: Vector) {
            self.cameraSize = cameraSize
            cameraPlane.point.z = cameraSize.y * cameraSizeScale + cameraZOffset
        }
        
        func intersect(ray: Ray) -> RayHit? {
            switch sphere.intersection(with: ray) {
            case .enter(let pt),
                 .enterExit(let pt, _),
                 .singlePoint(let pt):
                
                return RayHit(point: pt.point, normal: pt.normal, geometry: sphere)
            default:
                break
            }
            
            if let h = floorPlane.intersection(with: ray) {
                return RayHit(point: h, normal: floorPlane.normal, geometry: floorPlane)
            }
            
            return nil
        }
        
        func rayFromCamera(at point: BLPointI) -> Ray {
            var cameraXY = Vector(point) * cameraSizeScale
            cameraXY -= cameraSize * cameraSizeScale / 2
            cameraXY *= Vector(x: 1, y: -1)
            var cameraXZ = Vector3D(x: cameraXY.x, y: 0, z: cameraXY.y)
            cameraXZ += cameraPlane.point
            
            let cameraPoint = cameraPlane.point + cameraPlane.normal * cameraCenterOffset
            
            let dir = cameraXZ - cameraPoint
            
            return Ray(start: cameraXZ, direction: dir)
        }
    }
    
    struct RayHit {
        var point: Vector3D
        var normal: Vector3D
        var geometry: GeometricType
    }
}

private extension BLImageData {
    subscript(x x: Int, y y: Int) -> BLRgba32 {
        get {
            let offset = (x * MemoryLayout<BLRgba32>.stride + y * stride)
            
            return pixelData.load(fromByteOffset: offset, as: BLRgba32.self)
        }
        nonmutating set {
            let offset = (x * MemoryLayout<BLRgba32>.stride + y * stride)
            
            pixelData.storeBytes(of: newValue, toByteOffset: offset, as: BLRgba32.self)
        }
    }
}
