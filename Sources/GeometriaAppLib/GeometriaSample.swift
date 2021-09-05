import Foundation
import SwiftBlend2D
import Geometria
import ImagineUI
import Text
import Blend2DRenderer

private let instructions: String = """
R = Reset  |   Space = Pause   |   S = Change Stepping Length
N = (When Paused) Render Next Pixel
"""

class GeometriaSample: Blend2DSample {
    /// Specifies the number of ray-tracing steps (pixels) per frame.
    enum StepsCount: Int {
        case low = 20
        case medium = 500
        case high = 2000
        case veryHigh = 5000
        
        var toggleUp: StepsCount {
            switch self {
            case .low:
                return .medium
            case .medium:
                return .high
            case .high:
                return .veryHigh
            case .veryHigh:
                return .low
            }
        }
    }
    
    private let font: BLFont
    private var hasRequestedNext: Bool = false
    private var isResizing: Bool = false
    
    private var ui: ImagineUIWrapper
    private let topLeftLabels: StackView = StackView(orientation: .vertical)
    private let bottomLeftLabels: StackView = StackView(orientation: .vertical)
    private let stepsLabel: LabelControl = LabelControl()
    private let batcherLabel: LabelControl = LabelControl()
    private let progressLabel: LabelControl = LabelControl()
    private let instructionsLabel: LabelControl = LabelControl(text: instructions)
    
    var width: Int
    var height: Int
    var sampleRenderScale: BLPoint = .one
    var time: TimeInterval = 0
    var raytracer: Raytracer?
    var buffer: Blend2DBufferWriter?
    var isPaused: Bool = false
    var steps: StepsCount = .medium {
        didSet {
            updateLabels()
        }
    }
    
    weak var delegate: Blend2DSampleDelegate? {
        didSet {
            ui.delegate = delegate
        }
    }
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        time = 0
        font = Fonts.defaultFont(size: 12)
        ui = ImagineUIWrapper(size: BLSizeI(w: Int32(width), h: Int32(height)))
        restartRaytracing()
        createUI()
    }
    
    func createUI() {
        topLeftLabels.location = .init(x: 5, y: 5)
        topLeftLabels.spacing = 5
        topLeftLabels.areaIntoConstraintsMask = [.location]
        bottomLeftLabels.areaIntoConstraintsMask = []
        bottomLeftLabels.spacing = 5
        ui.rootView.addSubview(bottomLeftLabels)
        ui.rootView.addSubview(topLeftLabels)
        
        topLeftLabels.addArrangedSubview(stepsLabel)
        topLeftLabels.addArrangedSubview(batcherLabel)
        topLeftLabels.addArrangedSubview(progressLabel)
        
        bottomLeftLabels.addArrangedSubview(instructionsLabel)
        
        bottomLeftLabels.layout.makeConstraints { make in
            make.left == 5
            make.bottom == ui.rootView - 5
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        stepsLabel.text = "Steps per frame: \(steps.rawValue)"
        
        if let raytracer = raytracer {
            batcherLabel.text = "Pixel order mode: \(raytracer.batcher.displayName)"
            progressLabel.text = "Progress: \(String(format: "%.2lf", raytracer.progress * 100))%"
        }
    }
    
    func willStartLiveResize() {
        ui.willStartLiveResize()
        
        isResizing = true
    }
    
    func didEndLiveResize() {
        ui.didEndLiveResize()
        
        isResizing = false
        
        recreateRaytracer()
    }
    
    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height
        restartRaytracing()
        ui.resize(width: width, height: height)
    }
    
    func restartRaytracing() {
        guard !isResizing && width > 0 && height > 0 else {
            buffer = nil
            raytracer = nil
            return
        }
        
        isPaused = false
        hasRequestedNext = false
        
        recreateRaytracer()
    }
    
    func recreateRaytracer() {
        guard width > 0 && height > 0 else {
            return
        }
        
        let image = BLImage(width: width, height: height, format: .prgb32)
        let viewportSize = image.size.asVector2i
        
        let buffer = Blend2DBufferWriter(image: image)
        self.buffer = buffer
        
        raytracer = Raytracer(viewportSize: viewportSize, buffer: buffer)
        raytracer?.initialize()
    }
    
    func performLayout() {
        
    }
    
    // MARK: - UI
    
    func keyDown(event: KeyEventArgs) {
        if event.keyCode == .space {
            if raytracer?.hasWork == false {
                restartRaytracing()
                event.handled = true
            } else {
                isPaused.toggle()
                invalidateAll()
                event.handled = true
            }
        }
        if event.keyCode == .r {
            restartRaytracing()
            event.handled = true
        }
        if event.keyCode == .s {
            steps = steps.toggleUp
            
            invalidateAll()
            event.handled = true
        }
        if event.keyCode == .n {
            if isPaused {
                hasRequestedNext = true
                event.handled = true
            }
        }
        
        if !event.handled {
            ui.keyDown(event: event)
        }
    }
    
    func keyUp(event: KeyEventArgs) {
        ui.keyUp(event: event)
    }
    
    func mouseScroll(event: MouseEventArgs) {
        ui.mouseScroll(event: event)
    }
    
    func mouseMoved(event: MouseEventArgs) {
        ui.mouseMoved(event: event)
    }
    
    func mouseDown(event: MouseEventArgs) {
        ui.mouseDown(event: event)
    }
    
    func mouseUp(event: MouseEventArgs) {
        ui.mouseUp(event: event)
    }
    
    // MARK: -
    
    func update(_ time: TimeInterval) {
        self.time = time
        
        if let raytracer = raytracer, raytracer.hasWork {
            if isPaused {
                if hasRequestedNext {
                    hasRequestedNext = false
                    runRayTracer(steps: 1)
                }
            } else {
                runRayTracer(steps: steps.rawValue)
            }
            
            updateLabels()
        }
        
        batcherLabel.isVisible = raytracer != nil
        progressLabel.isVisible = raytracer != nil
        
        ui.update(time)
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
                for next in raytracer.nextCoords {
                    let box = BLBoxI(location: next.asBLPointI,
                                     size: BLPointI(x: 1, y: 1))
                    ctx.setFillStyle(BLRgba32.red)
                    ctx.fillBox(box)
                }
            }
        } else {
            ctx.setFillStyle(BLRgba32.white)
            ctx.fillAll()
        }
        
        ui.render(context: ctx)
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

class LabelControl: ControlView {
    private let textInset = EdgeInsets(left: 5, top: 2.5, right: 5, bottom: 2.5)
    private var label: Label
    
    var text: String {
        get { label.text }
        set { label.text = newValue }
    }
    
    var textColor: Color {
        get { label.textColor }
        set { label.textColor = newValue }
    }
    
    var attributedText: AttributedText {
        get { label.attributedText }
        set { label.attributedText = newValue }
    }
    
    convenience override init() {
        let font = Fonts.defaultFont(size: 12)
        
        self.init(font: Blend2DFont(font: font))
    }
    
    convenience init(text: String) {
        let font = Fonts.defaultFont(size: 12)
        
        self.init(font: Blend2DFont(font: font))
        
        self.text = text
    }
    
    init(font: Font) {
        label = Label(font: font)
        
        super.init()
        
        textColor = .white
        backColor = .black.withTransparency(60)
    }
    
    override func setupHierarchy() {
        addSubview(label)
    }
    
    override func setupConstraints() {
        label.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: textInset)
        }
    }
}
