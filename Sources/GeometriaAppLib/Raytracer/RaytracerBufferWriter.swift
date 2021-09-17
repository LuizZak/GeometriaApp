import blend2d
import Geometria

protocol RaytracerBufferWriter {
    var size: BLSizeI { get }
    
    func clearAll(color: BLRgba32)
    
    func setPixel(x: Int, y: Int, color: BLRgba32)
    func setPixel(at coord: Vector2i, color: BLRgba32)
}

extension RaytracerBufferWriter {
    func setPixel(at coord: Vector2i, color: BLRgba32) {
        setPixel(x: coord.x, y: coord.y, color: color)
    }
}
