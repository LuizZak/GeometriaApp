/// Batcher that serves a single pixel to render.
/// Used for debugging.
class SinglePixelBatcher: RaytracerBatcher {
    let displayName: String = "Single pixel"
    var viewportSize: Vector2i = .zero
    var batchesServedProgress: Double = 0
    var hasBatches: Bool = true
    var pixel: Vector2i
    
    init(pixel: Vector2i) {
        self.pixel = pixel
    }
    
    func initialize(viewportSize: Vector2i) {
        self.hasBatches = true
        self.viewportSize = viewportSize
    }
    
    func nextBatch() -> RaytracingBatch? {
        guard hasBatches else {
            return nil
        }
        
        hasBatches = false
        
        return SinglePixelBatch(pixel: pixel)
    }
    
    private class SinglePixelBatch: RaytracingBatch {
        var pixel: Vector2i?
        
        init(pixel: Vector2i?) {
            self.pixel = pixel
        }
        
        func nextPixel() -> Vector2i? {
            defer { pixel = nil }
            return pixel
        }
    }
}
