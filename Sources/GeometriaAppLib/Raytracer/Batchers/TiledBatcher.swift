import Geometria

/// Splits the viewport into squares to raytrace.
class TiledBatcher: RaytracerBatcher {
    typealias Pixel = Vector2i
    typealias PixelRect = Rectangle2<Pixel>
    
    private var viewportSize: Vector2i = .zero
    private var tileSize: Int
    private var tiles: [Tile] = []
    private var nextTileIndex: Int = 0
    
    var displayName: String = "Tiles/patchwork"
    
    var batchesServedProgress: Double {
        Double(nextTileIndex) / Double(tiles.count)
    }
    
    private(set) var hasBatches: Bool = false
    
    convenience init(splitting viewportSize: Vector2i, threadCount: Int) {
        let tileSize = viewportSize / (threadCount * 2)
        
        self.init(tileSize: tileSize.maximalComponent)
    }
    
    init(tileSize: Int) {
        self.tileSize = tileSize
    }
    
    func initialize(viewportSize: Vector2i) {
        self.viewportSize = viewportSize
        nextTileIndex = 0
        
        initializeTiles()
        hasBatches = tiles.count > 0
    }
    
    func nextBatch() -> RaytracingBatch? {
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
        
        let tilesX = Int((Double(viewportSize.x) / Double(tileSize)).rounded(.up))
        let tilesY = Int((Double(viewportSize.y) / Double(tileSize)).rounded(.up))
        
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
    }
    
    private func makeTile(bounds: PixelRect) -> Tile {
        return Tile(bounds: bounds)
    }
    
    class Tile: RaytracingBatch {
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
