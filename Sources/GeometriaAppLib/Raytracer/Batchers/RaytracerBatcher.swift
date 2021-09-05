import Geometria

/// Used to produce batching of pixels to raytrace.
protocol RaytracerBatcher {
    /// Display name of this batcher for UI.
    var displayName: String { get }
    
    /// If `false`, signals that the batcher has served all the pending batches.
    var hasBatches: Bool { get }
    
    // TODO: Would be better if initialization and batching were separated out.
    // TODO: Maybe make initialize() return an actual batcher that has nextBatch()?
    
    /// Initializes this batcher to its initial state with a given viewport size.
    /// Must be invoked before ``nextBatch(maxSize:)``.
    func initialize(viewportSize: Vector2i)
    
    /// Returns a new batch of screen-space pixels to render, with a maximal
    /// size of `maxSize`.
    /// 
    /// Returns `nil`, if all batches have been served.
    func nextBatch(maxSize: Int) -> [Vector2i]?
}
