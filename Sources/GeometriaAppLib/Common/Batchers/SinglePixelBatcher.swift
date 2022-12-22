import Geometry

/// Batcher that serves a single pixel to render.
/// Used for debugging.
public class SinglePixelBatcher: RenderingBatcher {
    public private(set) var viewportSize: ViewportSize = .zero
    public private(set) var pixel: PixelCoord
    public let displayName: String = "Single pixel"
    public private(set) var hasBatches: Bool = true
    public var batchesServedProgress: Double = 0
    
    public init(pixel: PixelCoord) {
        self.pixel = pixel
    }
    
    public func initialize(viewportSize: ViewportSize) {
        self.hasBatches = true
        self.viewportSize = viewportSize
    }
    
    public func nextBatch() -> RenderingBatch? {
        guard hasBatches else {
            return nil
        }
        
        hasBatches = false
        
        if pixel < .zero || !(pixel < viewportSize) {
            return nil
        }
        
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
