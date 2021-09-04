import SwiftBlend2D
import Geometria
import Foundation

class Raytracer {
    private var scene: Scene = Scene()
    private var camera: Camera
    private let numThreads = 8
    private let batchSize = 100
    private var totalPixels: Int64 = 0
    
    @ConcurrentValue private var currentPixels: Int64 = 0
    
    var viewportSize: Vector2i
    var buffer: RaytracerBufferWriter
    var hasWork: Bool = true
    
    /// The next coordinates the raytracer will fill.
    var nextCoords: [Vector2i] = []
    
    /// Progress of rendering, from 0.0 to 1.0, inclusive.
    @ConcurrentValue var progress: Double = 0.0
    
    /// Inverts ordering of pixel fillig from X-Y to Y-X.
    var invertRender = true
    
    var batcher: RaytracerBatcher
    
    init(viewportSize: Vector2i, buffer: RaytracerBufferWriter) {
        self.viewportSize = viewportSize
        self.buffer = buffer
        batcher = LineBatcher(viewportSize: viewportSize)
        camera = Camera(cameraSize: .init(viewportSize))
        nextCoords = []
        recreateCamera()
    }
    
    func initialize() {
        nextCoords = []
        totalPixels = Int64(viewportSize.x) * Int64(viewportSize.y)
        currentPixels = 0
        progress = 0.0
        buffer.clearAll(color: .cornflowerBlue)
        
        recreateCamera()
        recreateBatcher()
    }
    
    func recreateBatcher() {
        batcher = LineBatcher(viewportSize: viewportSize,
                              direction: .vertical)
    }
    
    func recreateCamera() {
        camera = Camera(cameraSize: .init(viewportSize))
    }
    
    func run(steps: Int) {
        guard hasWork else {
            return
        }
        
        guard let coords = batcher.nextBatch(maxSize: steps) else {
            hasWork = false
            return
        }
        
        nextCoords = coords
        
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
    
    // MARK: - Ray Casting
    
    func doRayCasting(at coord: Vector2i) {
        let ray = camera.rayFromCamera(at: coord)
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

struct RayHit {
    var point: Vector3D
    var normal: Vector3D
    var geometry: GeometricType
}
