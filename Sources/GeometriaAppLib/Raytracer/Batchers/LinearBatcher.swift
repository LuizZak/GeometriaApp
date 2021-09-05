import Geometria

/// A batcher that serves pixels to render in straight lines, weaving around
/// the screen space.
class LinearBatcher: RaytracerBatcher {
    private var initialized: Bool = false
    private let direction: Direction
    private var viewportSize: Vector2i = .zero
    
    /// List of starts of lines to feed threads
    private var lines: [Vector2i] = []
    private var nextLineIndex: Int = 0
    
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
        nextLineIndex = 0
        
        initializeLineList()
    }
    
    func nextBatch() -> RaytracingBatch? {
        guard hasBatches else { return nil }
        
        guard nextLineIndex < lines.count else {
            hasBatches = false
            return nil
        }
        
        defer { nextLineIndex += 1 }
        
        let maxLength: Int
        switch direction {
        case .horizontal:
            maxLength = viewportSize.x
        case .vertical:
            maxLength = viewportSize.y
        }
        
        return LineBatch(coord: lines[nextLineIndex], direction: direction, maxLength: maxLength)
    }
    
    private func initializeLineList() {
        lines.removeAll(keepingCapacity: true)
        
        let max: Int
        switch direction {
        case .horizontal:
            max = viewportSize.x
        case .vertical:
            max = viewportSize.y
        }
        
        for i in 0..<max {
            let x: Int
            let y: Int
            
            switch direction {
            case .horizontal:
                x = 0
                y = i
            case .vertical:
                x = i
                y = 0
            }
            
            lines.append(.init(x: x, y: y))
        }
    }
    
    private class LineBatch: RaytracingBatch {
        var isFinished: Bool = false
        var coord: Vector2i
        var direction: Direction
        var maxLength: Int
        
        init(coord: Vector2i, direction: Direction, maxLength: Int) {
            self.coord = coord
            self.direction = direction
            self.maxLength = maxLength
        }
        
        func nextPixel() -> Vector2i? {
            guard !isFinished else { return nil }
            
            var coord = coord
            
            switch direction {
            case .horizontal:
                coord.x += 1
                
                if coord.y >= maxLength {
                    isFinished = true
                    return nil
                }
                
            case .vertical:
                coord.y += 1
                
                if coord.x >= maxLength {
                    isFinished = true
                    return nil
                }
            }
            
            return coord
        }
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
