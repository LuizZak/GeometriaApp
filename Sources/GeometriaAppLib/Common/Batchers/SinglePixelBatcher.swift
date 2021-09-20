/// Batcher that serves a single pixel to render.
/// Used for debugging.
class SinglePixelBatcher: RenderingBatcher {
    let displayName: String = "Single pixel"
    var viewportSize: PixelCoord = .zero
    var batchesServedProgress: Double = 0
    var hasBatches: Bool = true
    var pixel: PixelCoord
    
    init(pixel: PixelCoord) {
        self.pixel = pixel
    }
    
    func initialize(viewportSize: PixelCoord) {
        self.hasBatches = true
        self.viewportSize = viewportSize
    }
    
    func nextBatch() -> RenderingBatch? {
        guard hasBatches else {
            return nil
        }
        
        hasBatches = false
        
        return SinglePixelBatch(pixel: pixel)
    }
    
    private class SinglePixelBatch: RenderingBatch {
        var pixel: PixelCoord?
        
        init(pixel: PixelCoord?) {
            self.pixel = pixel
        }
        
        func nextPixel() -> PixelCoord? {
            defer { pixel = nil }
            return pixel
        }
    }
}
