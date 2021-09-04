import SwiftBlend2D

class Blend2DBufferWriter: RaytracerBufferWriter {
    let image: BLImage
    
    var size: BLSizeI { image.size }
    
    init(image: BLImage) {
        self.image = image
    }
    
    func clearAll(color: BLRgba32) {
        let context = BLContext(image: image)!
        context.setFillStyle(color)
        context.fillAll()
        context.end()
    }
    
    func setPixel(x: Int, y: Int, color: BLRgba32) {
        assert(x >= 0 && x < size.w)
        assert(y >= 0 && y < size.h)
        
        let data = image.getImageData()
        
        data[x: x, y: y] = color
    }
}

private extension BLImageData {
    subscript(x x: Int, y y: Int) -> BLRgba32 {
        get {
            let offset = (x * MemoryLayout<BLRgba32>.stride + y * stride)
            
            return pixelData.load(fromByteOffset: offset, as: BLRgba32.self)
        }
        nonmutating set {
            let offset = (x * MemoryLayout<BLRgba32>.stride + y * stride)
            
            pixelData.storeBytes(of: newValue, toByteOffset: offset, as: BLRgba32.self)
        }
    }
}
