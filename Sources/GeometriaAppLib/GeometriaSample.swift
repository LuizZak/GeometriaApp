import Foundation
import SwiftBlend2D
import ImagineUI
import Text
import Blend2DRenderer
import QuartzCore
import Geometria

private let instructions: String = """
R = Reset  |   Space = Pause
"""

class GeometriaSample: Blend2DSample {
    private let _font: BLFont
    private var _isResizing: Bool = false
    private var _timeStarted: TimeInterval = 0.0
    private var _timeEnded: TimeInterval = 0.0
    private var _mouseLocation: BLPointI = .zero
    
    private var ui: ImagineUIWrapper
    
    private let topLeftLabels: StackView = StackView(orientation: .vertical)
    private let batcherLabel: LabelControl = LabelControl()
    private let stateLabel: LabelControl = LabelControl()
    private let progressLabel: LabelControl = LabelControl()
    private let totalTimeLabel: LabelControl = LabelControl()
    
    private let bottomLeftLabels: StackView = StackView(orientation: .vertical)
    private let instructionsLabel: LabelControl = LabelControl(text: instructions)
    
    private let mouseLocationLabel: LabelControl = LabelControl()
    
    var width: Int
    var height: Int
    var sampleRenderScale: BLPoint = .one
    var time: TimeInterval = 0
    var raytracer: RaytracerCoordinator?
    var buffer: Blend2DBufferWriter?
    
    weak var delegate: Blend2DSampleDelegate? {
        didSet {
            ui.delegate = delegate
        }
    }
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        time = 0
        _font = Fonts.defaultFont(size: 12)
        ui = ImagineUIWrapper(size: BLSizeI(w: Int32(width), h: Int32(height)))
        ui.sampleRenderScale = sampleRenderScale
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
        
        topLeftLabels.addArrangedSubview(stateLabel)
        topLeftLabels.addArrangedSubview(batcherLabel)
        topLeftLabels.addArrangedSubview(progressLabel)
        topLeftLabels.addArrangedSubview(totalTimeLabel)
        
        bottomLeftLabels.addArrangedSubview(instructionsLabel)
        bottomLeftLabels.addArrangedSubview(mouseLocationLabel)
        
        bottomLeftLabels.layout.makeConstraints { make in
            make.left == 5
            make.bottom == ui.rootView - 5
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        if let raytracer = raytracer {
            stateLabel.text = "State: \(raytracer.state.description)"
            batcherLabel.text = "Pixel order mode: \(raytracer.batcher.displayName)"
            progressLabel.text = "Progress of pixel batches served: \(String(format: "%.2lf", raytracer.progress * 100))%"
        }
        
        if _timeStarted != 0.0 {
            if _timeEnded != 0.0 {
                let timeString = String(format: "%.3lf", _timeEnded - _timeStarted)
                
                totalTimeLabel.text = "Total time (s): \(timeString)"
            } else {
                totalTimeLabel.text = "Total time (s): Running..."
            }
        } else {
            totalTimeLabel.text = "Total time (s): No run"
        }
    }
    
    func willStartLiveResize() {
        ui.willStartLiveResize()
        
        _isResizing = true
    }
    
    func didEndLiveResize() {
        ui.didEndLiveResize()
        
        _isResizing = false
        
        recreateRaytracer()
    }
    
    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height
        restartRaytracing()
        ui.resize(width: width, height: height)
    }
    
    func restartRaytracing() {
        raytracer?.cancel()
        
        guard !_isResizing && width > 0 && height > 0 else {
            buffer = nil
            raytracer = nil
            return
        }
        
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
        
        raytracer = RaytracerCoordinator(viewportSize: viewportSize, buffer: buffer)
        raytracer?.stateDidChange.addListener(owner: self) { [weak self] state in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if state == .finished {
                    self._timeEnded = CACurrentMediaTime()
                    self.invalidateAll()
                }
                self.updateLabels()
            }
        }
        raytracer?.initialize()
        raytracer?.start()
        
        _timeStarted = CACurrentMediaTime()
        _timeEnded = 0.0
    }
    
    func pause() {
        raytracer?.pause()
        
        invalidateAll()
    }
    
    func resume() {
        raytracer?.resume()
        
        invalidateAll()
    }
    
    func togglePause() {
        guard let raytracer = raytracer else {
            return
        }
        
        switch raytracer.state {
        case .unstarted, .finished, .cancelled:
            restartRaytracing()
        case .running:
            pause()
        case .paused:
            resume()
        }
    }
    
    // MARK: - UI
    
    func performLayout() {
        
    }
    
    func keyDown(event: KeyEventArgs) {
        if event.keyCode == .space {
            togglePause()
            event.handled = true
        }
        if event.keyCode == .r {
            restartRaytracing()
            event.handled = true
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
        
        _mouseLocation = BLPointI(x: Int32(event.location.x), y: Int32(event.location.y))
        mouseLocationLabel.text = "Mouse location: (x: \(_mouseLocation.x), y: \(_mouseLocation.y))"
        invalidateAll()
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
        
        if let raytracer = raytracer, raytracer.state == .running {
            updateLabels()
            invalidateAll()
        }
        
        stateLabel.isVisible = raytracer != nil
        batcherLabel.isVisible = raytracer != nil
        progressLabel.isVisible = raytracer != nil
        
        ui.update(time)
    }
    
    func invalidateAll() {
        delegate?.invalidate(bounds: .init(x: 0, y: 0, width: width, height: height))
    }
    
    func render(context ctx: BLContext) {
        if let buffer = buffer {
            buffer.usingImage { img in
                if sampleRenderScale == .one {
                    ctx.blitImage(img, at: BLPointI.zero)
                } else {
                    let rect = BLRect(x: 0,
                                      y: 0,
                                      w: Double(width) * sampleRenderScale.x,
                                      h: Double(height) * sampleRenderScale.y)
                    
                    ctx.blitScaledImage(img, rectangle: rect, imageArea: nil)
                }
            }
        } else {
            ctx.setFillStyle(BLRgba32.white)
            ctx.fillAll()
        }
        
        ui.render(context: ctx)
        
//        ctx.setFillStyle(BLRgba32.red)
//        ctx.setStrokeStyle(BLRgba32.red)
//
//        let px = BLRectI(location: _mouseLocation, size: .init(x: 1, y: 1))
//        ctx.fillRect(px)
//        ctx.setStrokeWidth(1)
//        let crosshairLength: Int32 = 10
//        ctx.strokeLine(p0: _mouseLocation - .init(x: crosshairLength, y: 0), p1: _mouseLocation + .init(x: crosshairLength, y: 0))
//        ctx.strokeLine(p0: _mouseLocation - .init(x: 0, y: crosshairLength), p1: _mouseLocation + .init(x: 0, y: crosshairLength))
    }
    
    func drawLabel(_ ctx: BLContext, text: String, topLeft: BLPoint) {
        let textInset = UIVector(x: 10, y: 5)
        let renderer = Blend2DRenderer(context: ctx)
        let layout = TextLayout(font: Blend2DFont(font: _font), text: text)
        let textBox = UIRectangle(location: topLeft.asUIVector, size: layout.size + textInset)
        
        renderer.setFill(.black.withTransparency(60))
        renderer.fill(textBox)
        renderer.setFill(.white)
        renderer.drawTextLayout(layout, at: topLeft.asUIVector + textInset / 2)
    }
    
    func drawLabel(_ ctx: BLContext, text: String, bottomLeft: BLPoint) {
        let textInset = UIVector(x: 10, y: 5)
        let renderer = Blend2DRenderer(context: ctx)
        let layout = TextLayout(font: Blend2DFont(font: _font), text: text)
        
        let textPoint = bottomLeft.asUIVector - UIVector(x: -textInset.x / 2, y: layout.size.y + textInset.y / 2)
        let boxPoint = bottomLeft.asUIVector - UIVector(x: 0, y: layout.size.y + textInset.y)
        
        let textBox = UIRectangle(location: boxPoint, size: layout.size + textInset)
        
        renderer.setFill(.black.withTransparency(60))
        renderer.fill(textBox)
        renderer.setFill(.white)
        renderer.drawTextLayout(layout, at: textPoint)
    }
    
    func drawPoint(_ ctx: BLContext, _ p: RVector2D) {
        ctx.setFillStyle(BLRgba32.white)
        ctx.fillCircle(x: p.x, y: p.y, radius: 3)
    }
    
    func strokeRect<R: RectangleType>(_ ctx: BLContext, _ rect: R) where R.Vector == RVector2D {
        ctx.setStrokeWidth(0.5)
        ctx.setStrokeStyle(BLRgba32.white)
        ctx.strokeRect(rect.asBLRect)
    }
    
    func strokeCircle(_ ctx: BLContext, _ circle: RCircle2D) {
        ctx.setStrokeWidth(0.5)
        ctx.setStrokeStyle(BLRgba32.white)
        ctx.strokeCircle(circle.asBLCircle)
    }
    
    func strokePolyLine(_ ctx: BLContext, _ polyLine: RPolyLine2D) {
        ctx.setStrokeWidth(0.5)
        ctx.setStrokeStyle(BLRgba32.white)
        ctx.strokePath(polyLine.asBLPath)
    }
    
    func drawLine(_ ctx: BLContext, _ line: RLineSegment2D, color: BLRgba32 = .lightGray) {
        ctx.setStrokeWidth(0.5)
        ctx.setStrokeStyle(color)
        ctx.strokeLine(line.asBLLine)
    }
    
    func drawPointNormal(_ ctx: BLContext, _ pointNormal: PointNormal<RVector2D>) {
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
        let line = RLineSegment2D(start: pointNormal.point,
                               end: pointNormal.point + pointNormal.normal * length)
        
        drawLine(ctx, line, color: color)
        drawPoint(ctx, pointNormal.point)
    }
    
    func drawIntersection(_ ctx: BLContext, _ intersect: ConvexLineIntersection<RVector2D>) {
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
    private let textInset = UIEdgeInsets(left: 5, top: 2.5, right: 5, bottom: 2.5)
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
