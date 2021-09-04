import Foundation
import SwiftBlend2D
import Geometria
import Text
import Blend2DRenderer

class GeometriaSample: Blend2DSample {
    enum StepsCount: Int {
        /// 20 steps per cycle
        case low = 20
        /// 200 steps per cycle
        case medium = 200
        /// 2000 steps per cycle
        case high = 2000
        
        var toggleUp: StepsCount {
            switch self {
            case .low:
                return .medium
            case .medium:
                return .high
            case .high:
                return .low
            }
        }
    }
    
    private let font: BLFont
    private let instructions: String = """
    R = Reset  |   Space = Pause   |   S = Change Stepping Length
    N = (When Paused) Render Next Pixel
    """
    private var hasRequestedNext = false
    
    var width: Int
    var height: Int
    var sampleRenderScale: BLPoint = .one
    var time: TimeInterval = 0
    var raytracer: Raytracer?
    var buffer: Blend2DBufferWriter?
    var isPaused: Bool = false
    var steps: StepsCount = .medium
    
    weak var delegate: Blend2DSampleDelegate?
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        time = 0
        font = Fonts.defaultFont(size: 12)
        restartRaytracing()
    }
    
    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height
        restartRaytracing()
    }
    
    func restartRaytracing() {
        guard width > 0 && height > 0 else {
            raytracer = nil
            return
        }
        
        isPaused = false
        hasRequestedNext = false
        
        let image = BLImage(width: width, height: height, format: .prgb32)
        let viewportSize = image.size
        
        let buffer = Blend2DBufferWriter(image: image)
        self.buffer = buffer
        
        raytracer = Raytracer(viewportSize: viewportSize, buffer: buffer)
        raytracer?.initialize()
    }
    
    func performLayout() {
        
    }
    
    func keyDown(event: KeyEventArgs) {
        if event.keyCode == .space {
            if raytracer?.hasWork == false {
                restartRaytracing()
            } else {
                isPaused.toggle()
                invalidateAll()
            }
        }
        if event.keyCode == .r {
            restartRaytracing()
        }
        if event.keyCode == .s {
            steps = steps.toggleUp
            
            invalidateAll()
        }
        if event.keyCode == .n {
            if isPaused {
                hasRequestedNext = true
            }
        }
    }
    
    func update(_ time: TimeInterval) {
        self.time = time
        
        guard let raytracer = raytracer else {
            return
        }
        guard raytracer.hasWork else {
            return
        }
        
        guard !isPaused else {
            if hasRequestedNext {
                hasRequestedNext = false
                runRayTracer(steps: 1)
            }
            
            return
        }
        
        runRayTracer(steps: steps.rawValue)
    }
    
    func runRayTracer(steps: Int) {
        raytracer?.run(steps: steps)
        invalidateAll()
    }
    
    func invalidateAll() {
        delegate?.invalidate(bounds: .init(x: 0, y: 0, width: width, height: height))
    }
    
    func render(context ctx: BLContext) {
        if let img = buffer?.image {
            ctx.blitImage(img, at: BLPointI.zero)
            
            if isPaused, let raytracer = raytracer {
                let box = BLBoxI(location: raytracer.coord.asBLPointI,
                                 size: BLPointI(x: 1, y: 1))
                ctx.setFillStyle(BLRgba32.red)
                ctx.fillBox(box)
            }
        } else {
            ctx.setFillStyle(BLRgba32.white)
            ctx.fillAll()
        }
        
        drawLabel(ctx, text: "Steps: \(steps.rawValue)", topLeft: .init(x: 5, y: 5))
        
        if let raytracer = raytracer {
            drawLabel(
                ctx,
                text: "Progress: \(String(format: "%.2lf", raytracer.progress * 100))%",
                topLeft: .init(x: 5, y: 30)
            )
        }
        
        drawLabel(ctx, text: instructions, bottomLeft: BLPoint(x: 5, y: Double(height) - 5))
    }
    
    func drawLabel(_ ctx: BLContext, text: String, topLeft: BLPoint) {
        let textInset = Vector(x: 10, y: 5)
        let renderer = Blend2DRenderer(context: ctx)
        let layout = TextLayout(font: Blend2DFont(font: font), text: text)
        let textBox = Rectangle(location: topLeft.asVector, size: layout.size + textInset)
        
        renderer.setFill(.black.withTransparency(60))
        renderer.fill(textBox)
        renderer.setFill(.white)
        renderer.drawTextLayout(layout, at: topLeft.asVector + textInset / 2)
    }
    
    func drawLabel(_ ctx: BLContext, text: String, bottomLeft: BLPoint) {
        let textInset = Vector(x: 10, y: 5)
        let renderer = Blend2DRenderer(context: ctx)
        let layout = TextLayout(font: Blend2DFont(font: font), text: text)
        
        let textPoint = bottomLeft.asVector - Vector(x: -textInset.x / 2, y: layout.size.y + textInset.y / 2)
        let boxPoint = bottomLeft.asVector - Vector(x: 0, y: layout.size.y + textInset.y)
        
        let textBox = Rectangle(location: boxPoint, size: layout.size + textInset)
        
        renderer.setFill(.black.withTransparency(60))
        renderer.fill(textBox)
        renderer.setFill(.white)
        renderer.drawTextLayout(layout, at: textPoint)
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
    
    func drawPointNormal(_ ctx: BLContext, _ pointNormal: PointNormal<Vector>) {
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
    
    func drawIntersection(_ ctx: BLContext, _ intersect: ConvexLineIntersection<Vector>) {
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
