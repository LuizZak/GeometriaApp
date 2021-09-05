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
    private(set) var hasBatches: Bool = false
    
    init(tileSize: Int) {
        self.tileSize = tileSize
    }
    
    func initialize(viewportSize: Vector2i) {
        self.viewportSize = viewportSize
        nextTileIndex = 0
        
        initializeTiles()
        hasBatches = tiles.count > 0
    }
    
    func nextBatch(maxSize: Int) -> [Pixel]? {
        guard hasBatches else {
            return nil
        }
        
        var pixels: [Pixel] = []
        pixels.reserveCapacity(maxSize)
        
        for _ in 0..<maxSize {
            guard let pixel = nextPixel() else {
                hasBatches = false
                break
            }
            
            pixels.append(pixel)
        }
        
        if pixels.isEmpty {
            return nil
        }
        
        return pixels
    }
    
    func nextPixel() -> Pixel? {
        if tiles.isEmpty {
            return nil
        }
        
        if nextTileIndex >= tiles.count {
            nextTileIndex = 0
        }
        
        if tiles[nextTileIndex].isAtEnd {
            tiles.remove(at: nextTileIndex)
            
            return nextPixel()
        }
        if let pixel = tiles[nextTileIndex].next() {
            nextTileIndex += 1
            
            return pixel
        }
        
        return nil
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
    
    struct Tile {
        var bounds: PixelRect
        var index: Int = 0
        var pixelCount: Int { bounds.width * bounds.height }
        var isAtEnd: Bool { index >= pixelCount }
        
        mutating func next() -> Pixel? {
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