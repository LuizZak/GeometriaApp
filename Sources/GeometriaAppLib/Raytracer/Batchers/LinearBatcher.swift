import Geometria

/// A batcher that serves pixels to render in straight lines, weaving around
/// the screen space.
class LinearBatcher: RaytracerBatcher {
    private var initialized: Bool = false
    private let direction: Direction
    private var viewportSize: Vector2i = .zero
    
    /// The next coordinate the raytracer will fill.
    private var coord: Vector2i = .zero
    
    let displayName: String = "Scanline"
    
    private(set) var hasBatches: Bool = false
    
    init(direction: Direction = .horizontal) {
        self.direction = direction
    }
    
    func initialize(viewportSize: Vector2i) {
        self.viewportSize = viewportSize
        initialized = true
        hasBatches = true
        coord = .zero
    }
    
    func nextBatch(maxSize: Int) -> [Vector2i]? {
        assert(initialized, "Attempted to invoke nextBatch(maxSize:) before invoking initialize(viewportSize:)")
        guard hasBatches else {
            return nil
        }
        
        var coords: [Vector2i] = []
        coords.reserveCapacity(maxSize)
        
        for _ in 0..<maxSize {
            coords.append(coord)
            
            if !incCoord() {
                hasBatches = false
                break
            }
        }
        
        return coords
    }
    
    private func incCoord() -> Bool {
        guard let next = nextCoord(from: coord) else {
            return false
        }
        
        coord = next
        
        return true
    }

    private func nextCoord(from coord: Vector2i) -> Vector2i? {
        var coord = coord
        
        switch direction {
        case .horizontal:
            coord.x += 1
            if coord.x >= viewportSize.x {
                coord.x = 0
                coord.y += 1
            }
            
            if coord.y >= viewportSize.y {
                return nil
            }
            
        case .vertical:
            coord.y += 1
            if coord.y >= viewportSize.y {
                coord.y = 0
                coord.x += 1
            }
            
            if coord.x >= viewportSize.x {
                return nil
            }
        }
        
        return coord
    }
    
    /// Specifies the primary direction a ``LinearBatcher`` serves in.
    enum Direction {
        /// Serves pixels by incrementing the X axis, and wrapping around the Y
        /// axis at the end.
        case horizontal
        
        /// Serves pixels by incrementing the Y axis, and wrapping around the X
        /// axis at the end.
        case vertical
    }
}
