import SwiftBlend2D

/// Class that manages rendering of batches of pixels.
class RendererWorker: CustomStringConvertible {
    @ConcurrentValue
    private static var nextId: Int = 0
    
    private let _id: Int
    
    //@ConcurrentValue
    private var _isPaused: Bool = false
    
    //@ConcurrentValue
    private var _isCancelled: Bool = false
    
    private weak var _context: RendererWorkerContext?
    
    var description: String {
        "Worker #\(_id) _isPaused: \(_isPaused) _isCancelled: \(_isCancelled)"
    }
    
    init(context: RendererWorkerContext) {
        _id = Self._nextId.modifyingValue({ i in defer { i += 1 }; return i })
        _context = context
    }
    
    func resume() {
        _print("resume() called")
        _isPaused = false
    }
    
    func pause() {
        _print("pause() called")
        _isPaused = true
    }
    
    func cancel() {
        _print("cancel() called")
        _isCancelled = true
    }
    
    func doWork() {
        _print("Worker started")
        defer { _print("Worker finished") }
        
        while !_isCancelled {
            if _isPaused { sleep(100); continue; }
            if _isCancelled { return }
            
            guard let context = _context else {
                _print("Worker has nil context")
                _isCancelled = true
                return
            }
            
            guard let renderer = context.renderer() else {
                _print("Context returned nil renderer")
                _isCancelled = true
                return
            }
            
            guard var batch = context.requestBatchSync() else {
                _print("Worker ran out of batches")
                _isCancelled = true
                return
            }
            
            while true {
                if _isPaused {
                    usleep(16_000) // 16 milliseconds
                    continue
                }
                if _isCancelled { return }
                
                guard let pixel = batch.nextPixel() else {
                    _print("Worker ran out of pixels")
                    break
                }
                
//                renderer.beginDebug()
                
                let color = renderer.render(pixelAt: pixel)
                
//                renderer.endDebug()
                
                context.setBufferPixel(at: pixel, color: color)
            }
        }
    }
    
    private func _print(_ string: @autoclosure () -> String) {
        //print("\(string()) - \(self)")
    }
}

protocol RendererWorkerContext: AnyObject {
    /// Gets the renderer object.
    func renderer() -> RendererType?
    
    /// Reports a pixel color for the buffer.
    func setBufferPixel(at coord: PixelCoord, color: BLRgba32)
    
    /// Requests a new batch of pixels to render.
    func requestBatchSync() -> RenderingBatch?
}
