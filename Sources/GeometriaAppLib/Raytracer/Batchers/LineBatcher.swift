import Geometria

/// A batcher that serves pixels to render in straight lines, weaving around
/// the screen space.
class LineBatcher: RaytracerBatcher {
    private let direction: Direction
    private var viewportSize: Vector2i
    
    /// The next coordinate the raytracer will fill.
    private var coord: Vector2i
    
    private(set) var hasBatches: Bool = true
    
    init(viewportSize: Vector2i, direction: Direction = .horizontal) {
        self.direction = direction
        self.viewportSize = viewportSize
        coord = .zero
        
        reset(viewportSize: viewportSize)
    }
    
    func reset(viewportSize: Vector2i) {
        self.viewportSize = viewportSize
        coord = .zero
        hasBatches = true
    }
    
    func nextBatch(maxSize: Int) -> [Vector2i]? {
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
    
    /// Specifies the primary direction a ``LineBatcher`` serves in.
    enum Direction {
        /// Serves pixels by incrementing the X axis, and wrapping around the Y
        /// axis at the end.
        case horizontal
        
        /// Serves pixels by incrementing the Y axis, and wrapping around the X
        /// axis at the end.
        case vertical
    }
}
