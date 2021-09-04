import Geometria

/// Used to produce batching of pixels to raytrace.
protocol RaytracerBatcher {
    /// If `false`, signals that the batcher has served all the pending batches.
    var hasBatches: Bool { get }
    
    /// Resets this batcher to its initial state with a given viewport size.
    func reset(viewportSize: Vector2i)
    
    /// Returns a new batch of screen-space pixels to render, with a maximal
    /// size of `maxSize`.
    /// 
    /// Returns `nil`, if all batches have been served.
    func nextBatch(maxSize: Int) -> [Vector2i]?
}
