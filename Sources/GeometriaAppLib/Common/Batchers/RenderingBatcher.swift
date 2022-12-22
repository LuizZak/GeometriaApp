/// Used to produce batching of pixels to render.
public protocol RenderingBatcher {
    /// Display name of this batcher for UI.
    var displayName: String { get }
    
    /// If `false`, signals that the batcher has served all the pending batches.
    var hasBatches: Bool { get }
    
    /// Returns a value, 0-1 inclusive, specifying the number of batches that
    /// where served vs the total.
    var batchesServedProgress: Double { get }
    
    // TODO: Would be better if initialization and batching were separated out.
    // TODO: Maybe make initialize() return an actual batcher that has nextBatch()?
    
    /// Initializes this batcher to its initial state with a given viewport size.
    /// Must be invoked before ``nextBatch(maxSize:)``.
    mutating func initialize(viewportSize: ViewportSize)
    
    /// Returns a new batch of screen-space pixels to render.
    /// 
    /// Returns `nil`, if all batches have been served.
    mutating func nextBatch() -> RenderingBatch?
}

/// A batch for a rendering thread.
public protocol RenderingBatch {
    /// Returns the next pixel to render from this batch.
    /// Returns `nil` in case no more pixels are available.
    mutating func nextPixel() -> PixelCoord?
}
