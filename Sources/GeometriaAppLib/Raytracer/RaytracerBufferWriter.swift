import blend2d

protocol RaytracerBufferWriter {
    var size: BLSizeI { get }
    
    func clearAll(color: BLRgba32)
    
    func setPixel(x: Int, y: Int, color: BLRgba32)
    func setPixel(at coord: BLPointI, color: BLRgba32)
}

extension RaytracerBufferWriter {
    func setPixel(at coord: BLPointI, color: BLRgba32) {
        setPixel(x: Int(coord.x), y: Int(coord.y), color: color)
    }
}
