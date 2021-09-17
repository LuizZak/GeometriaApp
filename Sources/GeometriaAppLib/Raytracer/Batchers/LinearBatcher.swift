/// A batcher that serves pixels to render in straight lines, weaving around
/// the screen space.
class LinearBatcher: RaytracerBatcher {
    private var initialized: Bool = false
    private let direction: Direction
    private var viewportSize: PixelCoord = .zero
    
    /// List of starts of lines to feed threads
    private var lines: [PixelCoord] = []
    private var nextLineIndex: Int = 0
    
    /// The next coordinate the raytracer will fill.
    private var coord: PixelCoord = .zero
    
    let displayName: String = "Scanline"
    
    var batchesServedProgress: Double {
        Double(nextLineIndex) / Double(lines.count)
    }
    
    private(set) var hasBatches: Bool = false
    
    init(direction: Direction = .horizontal) {
        self.direction = direction
    }
    
    func initialize(viewportSize: PixelCoord) {
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
        
        assert(lines[nextLineIndex] < viewportSize)
        
        return LineBatch(coord: lines[nextLineIndex], direction: direction, maxLength: maxLength)
    }
    
    private func initializeLineList() {
        lines.removeAll(keepingCapacity: true)
        
        let lastLine: Int
        switch direction {
        case .horizontal:
            lastLine = viewportSize.y
        case .vertical:
            lastLine = viewportSize.x
        }
        
        for i in 0..<lastLine {
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
        var coord: PixelCoord
        var direction: Direction
        var maxLength: Int
        
        init(coord: PixelCoord, direction: Direction, maxLength: Int) {
            self.coord = coord
            self.direction = direction
            self.maxLength = maxLength
        }
        
        func nextPixel() -> PixelCoord? {
            guard !isFinished else { return nil }
            
            let next = coord
            
            switch direction {
            case .horizontal:
                if coord.x >= maxLength {
                    isFinished = true
                    return nil
                }
                
                coord.x += 1
                
            case .vertical:
                if coord.y >= maxLength {
                    isFinished = true
                    return nil
                }
                
                coord.y += 1
            }
            
            return next
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
