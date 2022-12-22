import ImagineUI

/// Splits the viewport into squares to render.
public class TiledBatcher: RenderingBatcher {
    public typealias Pixel = PixelCoord
    public typealias PixelRect = UIIntRectangle
    
    private var viewportSize: ViewportSize = .zero
    private var tiles: [Tile] = []
    private var nextTileIndex: Int = 0
    private var tileSize: Int
    private var shuffleOrder: Bool
    
    public var displayName: String = "Tiles/patchwork"
    
    public var batchesServedProgress: Double {
        Double(nextTileIndex) / Double(tiles.count)
    }
    
    public private(set) var hasBatches: Bool = false
    
    public convenience init(splitting viewportSize: ViewportSize, estimatedThreadCount: Int, shuffleOrder: Bool = false) {
        let tileSize = viewportSize / (estimatedThreadCount * 2)
        
        self.init(tileSize: max(tileSize.width, tileSize.height), shuffleOrder: shuffleOrder)
    }
    
    public init(tileSize: Int, shuffleOrder: Bool = false) {
        self.tileSize = tileSize
        self.shuffleOrder = shuffleOrder
    }
    
    public func initialize(viewportSize: ViewportSize) {
        self.viewportSize = viewportSize
        nextTileIndex = 0
        
        initializeTiles()
        hasBatches = tiles.count > 0
    }
    
    public func nextBatch() -> RenderingBatch? {
        guard nextTileIndex < tiles.count else {
            hasBatches = false
            return nil
        }
        
        defer { nextTileIndex += 1 }
        
        return tiles[nextTileIndex]
    }
    
    private func initializeTiles() {
        tiles.removeAll()
        
        let viewRect = PixelRect(location: .zero, size: viewportSize)
        
        let tilesX = Int((Double(viewportSize.width) / Double(tileSize)).rounded(.up))
        let tilesY = Int((Double(viewportSize.height) / Double(tileSize)).rounded(.up))
        
        for i in 0..<tilesY {
            let y = i * tileSize
            
            for j in 0..<tilesX {
                let x = j * tileSize
                
                let rect = PixelRect(x: x, y: y, width: tileSize, height: tileSize)
                
                guard let res = rect.intersection(viewRect) else {
                    break
                }
                guard res.width > 0 && res.height > 0 else {
                    break
                }
                
                let tile = makeTile(bounds: res)
                
                tiles.append(tile)
            }
        }
        
        if shuffleOrder {
            tiles.shuffle()
        }
    }
    
    private func makeTile(bounds: PixelRect) -> Tile {
        return Tile(bounds: bounds)
    }
    
    class Tile: RenderingBatch {
        var bounds: PixelRect
        var index: Int = 0
        var pixelCount: Int { bounds.width * bounds.height }
        var isAtEnd: Bool { index >= pixelCount }
        
        init(bounds: PixelRect) {
            self.bounds = bounds
        }
        
        func nextPixel() -> Pixel? {
            guard !isAtEnd else {
                return nil
            }
            
            defer { index += 1 }
            
            let x = index % bounds.width
            let y = index / bounds.width
            
            return bounds.location + Pixel(x: x, y: y)
        }
    }
}
