import SwiftBlend2D
import Foundation
import Dispatch
import ImagineUI

/// Class that coordinates rendering dispatching across multi-threaded contexts.
final class RendererCoordinator: RendererWorkerContext {
    private var _renderer: RendererType
    private var _threadCount: Int
    private var _totalPixels: Int64 = 0
    
    private var _workers: [RendererWorker] = []
    
    /// Queue of rendering workers.
    private var _renderingWorkerQueue: DispatchQueue
    
    /// Queue for workers to request batches.
    private var _batchRequestQueue: DispatchQueue
    
    private(set) var state: State = .unstarted {
        didSet {
            if state != oldValue {
                _stateDidChange(old: oldValue, new: state)
            }
        }
    }
    
    @ConcurrentValue private var currentPixels: Int64 = 0
    
    @ValueChangedEvent<State>
    var stateDidChange
    
    var viewportSize: ViewportSize
    var buffer: RendererBufferWriter
    var hasWork: Bool = true
    
    /// Progress of rendering, from 0.0 to 1.0, inclusive.
    /// Based on number of remaining batchers, according to ``batcher``.
    var progress: Double {
        batcher.batchesServedProgress
    }
    
    var batcher: RenderingBatcher
    
    init(renderer: RendererType,
         viewportSize: ViewportSize,
         buffer: RendererBufferWriter,
         threadCount: Int,
         batcher: RenderingBatcher) {
        
        self._threadCount = threadCount
        self.viewportSize = viewportSize
        self.buffer = buffer
        
        self._renderer = renderer
        
        _renderingWorkerQueue = .init(label: "com.geometriaapp.rendering",
                                      qos: .background,
                                      attributes: .concurrent)
        _batchRequestQueue = .init(label: "com.geometriaapp.rendering.batcher",
                                   qos: .background)
        
        self.batcher = batcher
    }
    
    deinit {
        stopWorkQueue()
    }
    
    func initialize() {
        hasWork = true
        _totalPixels = Int64(viewportSize.width) * Int64(viewportSize.height)
        currentPixels = 0
        buffer.clearAll(color: .white)
        
        state = .unstarted
        
        resetBatcher()
        
        _renderer.isMultiThreaded = !(batcher is SinglePixelBatcher)
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
            let worker = RendererWorker(context: self)
            _workers.append(worker)
        }
    }
    
    func startWorkQueue() {
        for worker in _workers {
            _renderingWorkerQueue.async {
                worker.doWork()
            }
        }
        
        _renderingWorkerQueue.async(flags: .barrier) {
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
    
    /// Signals all workers using a block that is invoked for each active worker.
    func signalWorkers(_ block: @escaping (RendererWorker) -> Void) {
        for worker in _workers {
            block(worker)
        }
    }
    
    // MARK: RendererWorkerContext
    
    func renderer() -> RendererType? {
        return _renderer
    }
    
    func setBufferPixel(at coord: PixelCoord, color: BLRgba32) {
        assert(coord >= .zero && coord < viewportSize,
               "\(coord) is not within \(PixelCoord.zero) x \(viewportSize) limits")
        
        buffer.setPixel(at: coord, color: color)
    }
    
    func requestBatchSync() -> RenderingBatch? {
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
