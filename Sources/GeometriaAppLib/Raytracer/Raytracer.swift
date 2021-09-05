import SwiftBlend2D
import Geometria
import Foundation

class Raytracer {
    private var scene: Scene = Scene()
    private var camera: Camera
    private let threadCount = 8
    private let batchSize = 300
    private var totalPixels: Int64 = 0
    private var steps: Int = 0
    
    // Sky color for pixels that don't intersect with geometry
    private var skyColor: BLRgba32 = .cornflowerBlue
    
    private var raytracingQueue: DispatchQueue
    
    private(set) var state: State = .unstarted
    
    @ConcurrentValue private var currentPixels: Int64 = 0
    
    var viewportSize: Vector2i
    var buffer: RaytracerBufferWriter
    var hasWork: Bool = true
    
    /// The next coordinates the raytracer will fill.
    var nextCoords: [Vector2i] = []
    
    /// Progress of rendering, from 0.0 to 1.0, inclusive.
    @ConcurrentValue var progress: Double = 0.0
    
    var batcher: RaytracerBatcher
    
    init(viewportSize: Vector2i, buffer: RaytracerBufferWriter) {
        self.viewportSize = viewportSize
        self.buffer = buffer
        camera = Camera(cameraSize: .init(viewportSize))
        nextCoords = []
        raytracingQueue = .init(label: "com.geometriaapp.raytracing",
                                qos: .userInteractive,
                                attributes: .concurrent)
        
//        batcher = TiledBatcher(tileSize: 50)
//        batcher = SieveBatcher()
        batcher = LinearBatcher()
        
        recreateCamera()
    }
    
    func initialize() {
        nextCoords = []
        totalPixels = Int64(viewportSize.x) * Int64(viewportSize.y)
        currentPixels = 0
        progress = 0.0
        buffer.clearAll(color: .white)
        
        state = .unstarted
        
        recreateCamera()
        resetBatcher()
    }
    
    func pause() {
        guard hasWork else {
            return
        }
        
        state = .paused
    }
    
    func resume() {
        guard hasWork else {
            return
        }
        
        state = .running
    }
    
    func recreateCamera() {
        camera = Camera(cameraSize: .init(viewportSize))
    }
    
    func resetBatcher() {
        batcher.initialize(viewportSize: viewportSize)
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
        assert(coord >= .zero && coord < viewportSize, "\(coord) is not within \(Vector2i.zero) x \(viewportSize) limits")
        
        let ray = camera.rayFromCamera(at: coord)
        guard let hit = scene.intersect(ray: ray) else {
            buffer.setPixel(at: coord, color: skyColor)
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
        
        // Shading
        let shade = max(0.0, min(0.4, hit.normal.dot(-ray.direction)))
        color = color.faded(towards: .black, factor: Float(1 - shade))
        
        // Shadow or sunlight
        let shadow = calculateShadow(hit: hit)
        if shadow > 0 {
            // Shadow
            color = color.faded(towards: .black, factor: Float(0.5 * shadow))
        } else {
            // Sunlight direction
            let sunDirDot = max(0.0, min(1, pow(hit.normal.dot(-scene.sunDirection), 5)))
            color = color.faded(towards: .white, factor: Float(sunDirDot))
        }
        
        // Fade distant pixels to skyColor
        let far = 1000.0
        let dist = ray.a.distanceSquared(to: hit.point)
        let distFactor = max(0, min(1, Float(dist / (far * far))))
        color = color.faded(towards: skyColor, factor: distFactor)
        
        buffer.setPixel(at: coord, color: color)
    }
    
    /// Calculates shadow ratio. 0 = no shadow, 1 = fully shadowed, values in
    /// between specify the percentage of shadow rays that where obstructed by
    /// geometry.
    func calculateShadow(hit: RayHit, rays: Int = 1) -> Double {
        if rays == 1 {
            let ray = Ray(start: hit.point, direction: -scene.sunDirection)
            if scene.intersect(ray: ray, ignoring: hit.geometry) != nil {
                return 1.0
            }
            
            return 0.0
        }
        
        let mag = 150.0
        var shadowsHit = 0.0
        
        for _ in 0..<rays {
            var shadowLine = Line3(a: hit.point, b: hit.point - scene.sunDirection * mag)
            shadowLine.b.x += Double.random(in: -1...1)
            shadowLine.b.y += Double.random(in: -1...1)
            shadowLine.b.z += Double.random(in: -1...1)
            
            let ray = Ray.init(shadowLine)
            if scene.intersect(ray: ray, ignoring: hit.geometry) != nil {
                shadowsHit += 1
            }
        }
        
        return shadowsHit / Double(rays)
    }
    
    enum State: CustomStringConvertible {
        case unstarted
        case running
        case finished
        case paused
        
        var description: String {
            switch self {
            case .unstarted:
                return "Unstarted"
            case .running:
                return "Running"
            case .finished:
                return "Finished"
            case .paused:
                return "Paused"
            }
        }
    }
}

struct RayHit {
    var point: Vector3D
    var normal: Vector3D
    var geometry: GeometricType
}
