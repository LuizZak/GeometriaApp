import SwiftBlend2D
import Geometria
import Foundation
import Dispatch
import ImagineUI

/// Class that coordinates raytracing dispatching across multi-threaded contexts.
class RaytracerCoordinator: RaytracerWorkerContext {
    private var _raytracer: Raytracer
    private let _threadCount = 8
    private var _totalPixels: Int64 = 0
    
    private var _workers: [RaytracingWorker] = []
    
    /// Queue of raytracer workers.
    private var _raytracingQueue: DispatchQueue
    
    /// Queue for workers to request batches.
    private var _batchRequestQueue: DispatchQueue
    
    private(set) var state: State = .unstarted {
        didSet {
            if state != oldValue {
                _stateDidChange.publishEvent(state)
            }
        }
    }
    
    @ConcurrentValue private var currentPixels: Int64 = 0
    
    @Event var stateDidChange: EventSource<State>
    
    var viewportSize: Vector2i
    var buffer: RaytracerBufferWriter
    var hasWork: Bool = true
    
    /// Progress of rendering, from 0.0 to 1.0, inclusive.
    /// Based on number of remaining batchers, according to ``batcher``.
    var progress: Double {
        batcher.batchesServedProgress
    }
    
    var batcher: RaytracerBatcher
    
    init(viewportSize: Vector2i, buffer: RaytracerBufferWriter) {
        self.viewportSize = viewportSize
        self.buffer = buffer
        
        self._raytracer = Raytracer(scene: Scene(),
                                    camera: Camera(cameraSize: .init(viewportSize)),
                                    viewportSize: viewportSize)
        
        _raytracingQueue = .init(label: "com.geometriaapp.raytracing",
                                 qos: .default,
                                 attributes: .concurrent)
        _batchRequestQueue = .init(label: "com.geometriaapp.raytracing.batcher",
                                   qos: .default)
        
//        batcher = SinglePixelBatcher(pixel: .init(x: 225, y: 150)) // Transparent sphere - top-right corner
//        batcher = SinglePixelBatcher(pixel: .init(x: 200, y: 173)) // Transparent sphere - center
//        batcher = SinglePixelBatcher(pixel: .init(x: 189, y: 184)) // Transparent sphere - bottom-left center of refraction 'anomaly'
        batcher = TiledBatcher(splitting: viewportSize,
                               estimatedThreadCount: _threadCount * 2,
                               shuffleOrder: true)
//        batcher = SieveBatcher()
//        batcher = LinearBatcher()
        
        recreateCamera()
    }
    
    deinit {
        stopWorkQueue()
    }
    
    func initialize() {
        hasWork = true
        _totalPixels = Int64(viewportSize.x) * Int64(viewportSize.y)
        currentPixels = 0
        buffer.clearAll(color: .white)
        
        state = .unstarted
        
        recreateCamera()
        resetBatcher()
    }
    
    func start() {
        guard hasWork, state == .unstarted else {
            return
        }
        
        prepareWorkQueue()
        startWorkQueue()
        
        state = .running
    }
    
    func pause() {
        guard hasWork else {
            return
        }
        
        signalWorkers { worker in
            worker.pause()
        }
        
        state = .paused
    }
    
    func resume() {
        guard hasWork else {
            return
        }
        
        signalWorkers { worker in
            worker.resume()
        }
        
        state = .running
    }
    
    func cancel() {
        guard hasWork, state == .running else {
            return
        }
        
        signalWorkers { worker in
            worker.cancel()
        }
        
        state = .cancelled
    }
    
    func recreateCamera() {
        _raytracer.camera = Camera(cameraSize: .init(viewportSize))
    }
    
    func resetBatcher() {
        batcher.initialize(viewportSize: viewportSize)
    }
    
    // MARK: Multi-threading
    
    func prepareWorkQueue() {
        if _threadCount <= 0 {
            cancel()
            return
        }
        
        _workers.removeAll()
        
        for _ in 0..<_threadCount {
            let worker = RaytracingWorker(context: self)
            _workers.append(worker)
        }
    }
    
    func startWorkQueue() {
        for worker in _workers {
            _raytracingQueue.async {
                worker.doWork()
            }
        }
        
        _raytracingQueue.async(flags: .barrier) {
            if self.state == .running {
                self.state = .finished
            }
        }
    }
    
    func stopWorkQueue() {
        for worker in _workers {
            worker.cancel()
        }
        
        _workers.removeAll()
    }
    
    /// Signals all raytracing workers using a block that is invoked for each
    /// active worker.
    func signalWorkers(_ block: @escaping (RaytracingWorker) -> Void) {
        for worker in _workers {
            block(worker)
        }
    }
    
    // MARK: RaytracerWorkerContext
    
    func raytracer() -> Raytracer? {
        return _raytracer
    }
    
    func setBufferPixel(at coord: Vector2i, color: BLRgba32) {
        assert(coord >= .zero && coord < viewportSize,
               "\(coord) is not within \(Vector2i.zero) x \(viewportSize) limits")
        
        buffer.setPixel(at: coord, color: color)
    }
    
    func requestBatchSync() -> RaytracingBatch? {
        _batchRequestQueue.sync(flags: .barrier) {
            batcher.nextBatch()
        }
    }
    
    enum State: CustomStringConvertible {
        case unstarted
        case running
        case finished
        case paused
        case cancelled
        
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
            case .cancelled:
                return "Cancelled"
            }
        }
    }
}
