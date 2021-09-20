import blend2d

protocol RendererBufferWriter {
    var size: BLSizeI { get }
    
    func clearAll(color: BLRgba32)
    
    func setPixel(x: Int, y: Int, color: BLRgba32)
    func setPixel(at coord: PixelCoord, color: BLRgba32)
}

extension RendererBufferWriter {
    func setPixel(at coord: PixelCoord, color: BLRgba32) {
        setPixel(x: coord.x, y: coord.y, color: color)
    }
}
