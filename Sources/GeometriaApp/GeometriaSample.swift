import Foundation
import SwiftBlend2D
import Geometria

class GeometriaSample: Blend2DSample {
    var width: Int
    var height: Int
    var sampleRenderScale: BLPoint = .one
    var time: TimeInterval = 0
    var buffer: BLImage?
    
    weak var delegate: Blend2DSampleDelegate?
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        time = 0
        recreateBackBuffer()
    }
    
    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height
        recreateBackBuffer()
    }
    
    func recreateBackBuffer() {
        guard width > 0 && height > 0 else {
            buffer = nil
            return
        }
        
        let image = BLImage(width: width, height: height, format: .prgb32)
        guard let ctx = BLContext(image: image, options: nil) else {
            buffer = nil
            return
        }
        
        ctx.setFillStyle(BLRgba32.cornflowerBlue)
        ctx.fillAll()
        
        ctx.end()
        
        buffer = image
    }
    
    func performLayout() {
        
    }
    
    func update(_ time: TimeInterval) {
        self.time = time
//        delegate?.invalidate(bounds: .init(x: 0, y: 0, width: width, height: height))
    }
    
    func render(context ctx: BLContext) {
        if let img = buffer {
            ctx.blitImage(img, at: BLPointI.zero)
        } else {
            ctx.setFillStyle(BLRgba32.white)
            ctx.fillAll()
        }
    }
    
    func drawPoint(_ ctx: BLContext, _ p: Vector) {
        ctx.setFillStyle(BLRgba32.white)
        ctx.fillCircle(x: p.x, y: p.y, radius: 3)
    }
    
    func strokeRect<R: RectangleType>(_ ctx: BLContext, _ rect: R) where R.Vector == Vector {
        ctx.setStrokeWidth(0.5)
        ctx.setStrokeStyle(BLRgba32.white)
        ctx.strokeRect(rect.asBLRect)
    }
    
    func strokeCircle(_ ctx: BLContext, _ circle: Circle) {
        ctx.setStrokeWidth(0.5)
        ctx.setStrokeStyle(BLRgba32.white)
        ctx.strokeCircle(circle.asBLCircle)
    }
    
    func strokePolyLine(_ ctx: BLContext, _ polyLine: PolyLine) {
        ctx.setStrokeWidth(0.5)
        ctx.setStrokeStyle(BLRgba32.white)
        ctx.strokePath(polyLine.asBLPath)
    }
    
    func drawLine(_ ctx: BLContext, _ line: LineSegment, color: BLRgba32 = .lightGray) {
        ctx.setStrokeWidth(0.5)
        ctx.setStrokeStyle(color)
        ctx.strokeLine(line.asBLLine)
    }
    
    func drawPointNormal(_ ctx: BLContext, _ pointNormal: PointNormal<Vector2D>) {
        let color: BLRgba32
        switch (pointNormal.normal.x, pointNormal.normal.y) {
        case (1, 0), (-1, 0):
            color = .red
        case (0, 1), (0, 1):
            color = .blue
        default:
            color = .red
        }
        
        let length: Double = 15
        let line = LineSegment(start: pointNormal.point,
                               end: pointNormal.point + pointNormal.normal * length)
        
        drawLine(ctx, line, color: color)
        drawPoint(ctx, pointNormal.point)
    }
    
    func drawIntersection(_ ctx: BLContext, _ intersect: ConvexLineIntersection<Vector2D>) {
        switch intersect {
        case .singlePoint(let pt), .enter(let pt), .exit(let pt):
            drawPointNormal(ctx, pt)
            
        case let .enterExit(pt1, pt2):
            drawPointNormal(ctx, pt1)
            drawPointNormal(ctx, pt2)
            
        case .contained:
            break
        case .noIntersection:
            break
        }
    }
}
