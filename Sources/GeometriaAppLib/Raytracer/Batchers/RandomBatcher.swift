import Geometria
import Foundation

/// A batcher that serves remaining pixels at random.
class RandomBatcher: RaytracerBatcher {
    private var hasInitialized = false
    private var viewportSize: Vector2i = .zero
    private var nextIndex: Int = 0
    private var pixels: [Vector2i]
    
    /// The maximum number of pixels to attempt to swap in the pixels list.
    ///
    /// A lower number will generate a simple scanline batch of pixels where
    /// occasionally pixels will be randomly sampled instead of scanlined,
    /// while a higher number will be more random, but with a higher
    /// initialization cost.
    var maxRandomizedSwaps: Int = 10_000
    
    let displayName: String = "Random"
    
    var hasBatches: Bool { nextIndex < pixels.count }
    
    init() {
        self.pixels = []
    }
    
    func initialize(viewportSize: Vector2i) {
        self.viewportSize = viewportSize
        hasInitialized = true
        
        let pixelCount = viewportSize.x * viewportSize.y
        if pixels.count != pixelCount {
            recreatePixelList(pixelCount: pixelCount)
        }
        
        nextIndex = 0
    }
    
    func recreatePixelList(pixelCount: Int) {
        pixels.removeAll(keepingCapacity: true)
        var index = 0
        var x = 0
        var y = 0
        while index < pixelCount {
            defer { index += 1 }
            
            defer { x += 1 }
            if x >= viewportSize.x {
                x = 0
                y += 1
            }
            
            pixels.append(.init(x: x, y: y))
        }
        
        index = 0
        let swaps = min(maxRandomizedSwaps, pixelCount)
        while index < swaps {
            defer { index += 1 }
            
            let i = Int.random(in: 0..<pixelCount)
            let j = Int.random(in: 0..<pixelCount)
            
            pixels.swapAt(i, j)
        }
    }
    
    func nextBatch(maxSize: Int) -> [Vector2i]? {
        assert(hasInitialized, "Attempted to invoke nextBatch(maxSize:)) before calling initialize(viewportSize:)")
        guard hasBatches else {
            return nil
        }
        
        var result: [Vector2i] = []
        result.reserveCapacity(maxSize)
        
        for _ in 0..<maxSize {
            guard let next = nextPixel() else {
                break
            }
            
            result.append(next)
        }
        
        return result
    }
    
    func nextPixel() -> Vector2i? {
        guard nextIndex < pixels.count else {
            return nil
        }
        
        defer { nextIndex += 1 }
        
        return pixels[nextIndex]
    }
}
