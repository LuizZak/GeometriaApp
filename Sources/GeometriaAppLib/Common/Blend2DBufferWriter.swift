import Dispatch
import SwiftBlend2D

public class Blend2DBufferWriter: RendererBufferWriter {
    private let imageQueue = DispatchQueue(
        label: "com.geometriaapp.rendering.buffer",
        qos: .background,
        attributes: [.concurrent]
    )
    
    private let image: BLImage
    private let imageData: BLImageData
    
    public var size: BLSizeI { image.size }
    
    public init(image: BLImage) {
        self.image = image
        self.imageData = image.getImageData()
    }
    
    public func clearAll(color: BLRgba32) {
        let context = BLContext(image: image)!
        context.setFillStyle(color)
        context.fillAll()
        context.end()
    }
    
    public func setPixel(x: Int, y: Int, color: BLRgba32) {
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
            precondition(x >= 0 && x < Int(size.w))
            precondition(y >= 0 && y < Int(size.h))
            
            let offset = (x * MemoryLayout<BLRgba32>.stride + y * stride)
            
            return pixelData.load(fromByteOffset: offset, as: BLRgba32.self)
        }
        nonmutating set {
            precondition(x >= 0 && x < Int(size.w))
            precondition(y >= 0 && y < Int(size.h))

            let offset = (x * MemoryLayout<BLRgba32>.stride + y * stride)
            
            pixelData.storeBytes(of: newValue, toByteOffset: offset, as: BLRgba32.self)
        }
    }
}
