import Dispatch
import SwiftBlend2D

class Blend2DBufferWriter: RendererBufferWriter {
    private let imageQueue = DispatchQueue(label: "com.geometriaapp.rendering.buffer",
                                           qos: .default,
                                           attributes: [.concurrent])
    private let image: BLImage
    private let imageData: BLImageData
    
    var size: BLSizeI { image.size }
    
    init(image: BLImage) {
        self.image = image
        self.imageData = image.getImageData()
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
        
        // TODO: Not enabled for now because it causes some performance hitches,
        // TODO: but doesn't seem to affect the memory integrity anyway.
        
//        imageQueue.async {
        let data = imageData
        
        data[x: x, y: y] = color
//        }
    }
    
    func usingImage(_ block: (BLImage) -> Void) {
        block(image)
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