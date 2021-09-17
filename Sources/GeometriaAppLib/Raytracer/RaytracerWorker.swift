import SwiftBlend2D
import Geometria

/// Class that manages raytracing of batches of pixels.
class RaytracingWorker: CustomStringConvertible {
    @ConcurrentValue private static var nextId: Int = 0
    
    private let _id: Int
    @ConcurrentValue private var _isPaused: Bool = false
    @ConcurrentValue private var _isCancelled: Bool = false
    private weak var _context: RaytracerWorkerContext?
    
    var description: String {
        "Worker #\(_id) _isPaused: \(_isPaused) _isCancelled: \(_isCancelled)"
    }
    
    init(context: RaytracerWorkerContext) {
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
            
            if let raytracer = _context?.raytracer(), var batch = _context?.requestBatchSync() {
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
                    
//                    raytracer.beginDebug()
                    
                    let color = raytracer.raytrace(pixelAt: pixel)
                    
//                    raytracer.endDebug()
                    
                    if let context = _context {
                        context.setBufferPixel(at: pixel, color: color)
                    } else {
                        _print("Worker has nil context")
                        _isCancelled = true
                        return
                    }
                }
            } else {
                _print("Worker ran out of batches")
                _isCancelled = true
                return
            }
        }
    }
    
    private func _print(_ string: @autoclosure () -> String) {
        //print("\(string()) - \(self)")
    }
}

protocol RaytracerWorkerContext: AnyObject {
    /// Gets the raytracer object.
    func raytracer() -> Raytracer?
    
    /// Reports a pixel color for the buffer.
    func setBufferPixel(at coord: Vector2i, color: BLRgba32)
    
    /// Requests a new batch of pixels to raytrace.
    func requestBatchSync() -> RaytracingBatch?
}
