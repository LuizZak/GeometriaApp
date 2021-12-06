import Foundation
import SwiftBlend2D
import ImagineUI
import Text
import Blend2DRenderer

private let instructions: String = """
R = Reset  |   Space = Pause
"""

public class RaytracerApp: Blend2DApp {
    private var _updateTimer: SchedulerTimerType?
    private let _font: Font
    private var _isResizing: Bool = false
    private var _timeStarted: TimeInterval = 0.0
    private var _timeEnded: TimeInterval = 0.0
    private var _mouseLocation: BLPointI = .zero
    
    private var threadCount: Int = 12
    
    private var ui: RaytracerUI
    
    var rendererCoordinator: RendererCoordinator?
    var buffer: Blend2DBufferWriter?
    
    public var width: Int
    public var height: Int
    public var appRenderScale: BLPoint = .one
    public var time: TimeInterval = 0
    
    public weak var delegate: Blend2DAppDelegate? {
        didSet {
            ui.delegate = delegate
        }
    }
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        time = 0
        _font = Fonts.defaultFont(size: 12)
        
        let uiWrapper = ImagineUIWrapper(size: BLSizeI(w: Int32(width), h: Int32(height)))
        ui = RaytracerUI(uiWrapper: uiWrapper)

        restartRendering()
        createUI()
    }

    deinit {
        _updateTimer?.invalidate()
    }
    
    func createUI() {
        let sceneGraphWidth = 250.0

        let sceneGraphUI = SceneGraphUIComponent(width: sceneGraphWidth)
        ui.addComponent(sceneGraphUI)
        let labelsContainer = ui.addComponentInReservedView(StatusLabelsComponent())

        labelsContainer.layout.makeConstraints { make in
            (make.top, make.right, make.bottom) == ui.rootContainer
            make.right(of: sceneGraphUI.sidePanel)
        }
    }
    
    public func willStartLiveResize() {
        ui.willStartLiveResize()
        
        _isResizing = true
    }
    
    public func didEndLiveResize() {
        ui.didEndLiveResize()
        
        _isResizing = false
        
        recreateRenderer()
    }
    
    public func resize(width: Int, height: Int) {
        self.width = width
        self.height = height

        ui.resize(width: width, height: height)

        restartRendering()
    }
    
    func restartRendering() {
        _updateTimer = Scheduler.instance.scheduleTimer(interval: 1 / 60.0, repeats: true) { [weak self] in
            guard let self = self else { return }

            self.update(UISettings.timeInSeconds())
        }

        rendererCoordinator?.cancel()
        
        guard !_isResizing && width > 0 && height > 0 else {
            buffer = nil
            rendererCoordinator = nil
            return
        }
        
        recreateRenderer()
    }
    
    func recreateRenderer() {
        guard width > 0 && height > 0 else {
            return
        }
        
        let image = BLImage(width: width, height: height, format: .prgb32)
        let viewportSize = image.size.asViewportSize
        
        let buffer = Blend2DBufferWriter(image: image)
        self.buffer = buffer
        
//        let batcher = SinglePixelBatcher(pixel: .init(x: 173, y: 171)) // Transparent sphere - bottom-left center of refraction 'anomaly'
//        let batcher = SinglePixelBatcher(pixel: .init(x: 261, y: 173)) // Reflection of transparent sphere on right sphere
//        let batcher = SinglePixelBatcher(pixel: .init(x: 273, y: 150)) // Refractive cylinder
//        let batcher = SinglePixelBatcher(pixel: .init(x: 172, y: 156)) // Bug in refractive bouncing in left sphere
//        let batcher = SinglePixelBatcher(pixel: .init(x: 255, y: 224)) // Bug in refractive bouncing in cylinder's base
//        let batcher = SinglePixelBatcher(pixel: .init(x: 177, y: 202)) // Top of cube-cylinder subtraction demo scene
//        let batcher = SinglePixelBatcher(pixel: .init(x: 180, y: 195)) // Left of cube-cylinder subtraction demo scene bug
        let batcher = TiledBatcher(splitting: viewportSize,
                                   estimatedThreadCount: threadCount * 2,
                                   shuffleOrder: true)
//        let batcher = SieveBatcher()
//        let batcher = LinearBatcher()
        
        // TODO: Derive camera configuration from the demo scene builders.

        #if false
        
        let scene = RaytracingDemoScene3.makeScene()
        
        let renderer = Raytracer(
            scene: scene,
            camera: Camera(viewportSize: viewportSize),
            viewportSize: viewportSize
        )
        
        #else

        let scene = RaymarchingDemoScene3.makeScene()
        
        let renderer = Raymarcher(
            scene: scene,
            camera: Camera(viewportSize: viewportSize),
            viewportSize: viewportSize
        )
        
        #endif
        
        rendererCoordinator = RendererCoordinator(
            renderer: renderer,
            viewportSize: viewportSize,
            buffer: buffer,
            threadCount: threadCount,
            batcher: batcher
        )

        ui.rendererCoordinatorChanged(rendererCoordinator)
        ui.rendererChanged(renderer)
        
        rendererCoordinator?.stateDidChange.addListener(owner: self) { [weak self] (_, change) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if change.newValue == .finished {
                    self._timeEnded = UISettings.timeInSeconds()
                    self.invalidateAll()
                }
            }
        }
        rendererCoordinator?.initialize()
        rendererCoordinator?.start()
        
        _timeStarted = UISettings.timeInSeconds()
        _timeEnded = 0.0
    }
    
    func pause() {
        rendererCoordinator?.pause()
        
        invalidateAll()
    }
    
    func resume() {
        rendererCoordinator?.resume()
        
        invalidateAll()
    }
    
    func togglePause() {
        guard let renderer = rendererCoordinator else {
            return
        }
        
        switch renderer.state {
        case .unstarted, .finished, .cancelled:
            restartRendering()
        case .running:
            pause()
        case .paused:
            resume()
        }
    }
    
    // MARK: - UI
    
    public func performLayout() {
        ui.performLayout()
    }
    
    public func keyDown(event: KeyEventArgs) {
        if event.keyCode == .space {
            togglePause()
            event.handled = true
        }
        if event.keyCode == .r {
            restartRendering()
            event.handled = true
        }
        
        if !event.handled {
            ui.keyDown(event: event)
        }
    }
    
    public func keyUp(event: KeyEventArgs) {
        ui.keyUp(event: event)
    }
    
    public func mouseScroll(event: MouseEventArgs) {
        ui.mouseScroll(event: event)
    }
    
    public func mouseMoved(event: MouseEventArgs) {
        ui.mouseMoved(event: event)
        
        invalidateAll()
    }
    
    public func mouseDown(event: MouseEventArgs) {
        ui.mouseDown(event: event)
    }
    
    public func mouseUp(event: MouseEventArgs) {
        ui.mouseUp(event: event)
    }
    
    // MARK: -
    
    public func update(_ time: TimeInterval) {
        self.time = time
        
        if let renderer = rendererCoordinator, renderer.state == .running {
            invalidateAll()
        }
        
        ui.update(time)
    }
    
    func invalidateAll() {
        delegate?.invalidate(bounds: .init(x: 0, y: 0, width: Double(width), height: Double(height)))
    }
    
    public func render(context ctx: BLContext, scale: BLPoint, clipRegion: ClipRegion) {
        if let buffer = buffer {
            buffer.usingImage { img in
                ctx.save()
                ctx.clipToRect(clipRegion.bounds().scaled(by: scale).asBLRect)

                if scale == .one {
                    ctx.blitImage(img, at: BLPointI.zero)
                } else {
                    let rect = BLRect(
                        x: 0,
                        y: 0,
                        w: Double(width) * scale.x,
                        h: Double(height) * scale.y
                    )
                    
                    ctx.blitScaledImage(img, rectangle: rect, imageArea: nil)
                }

                ctx.restore()
            }
        } else {
            ctx.setFillStyle(BLRgba32.white)
            ctx.fillAll()
        }
        
        ui.render(context: ctx, scale: scale)
        
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
        let layout = TextLayout(font: _font, text: text)
        let textBox = UIRectangle(location: topLeft.asUIVector, size: layout.size + textInset)
        
        renderer.setFill(.black.withTransparency(60))
        renderer.fill(textBox)
        renderer.setFill(.white)
        renderer.drawTextLayout(layout, at: topLeft.asUIVector + textInset / 2)
    }
    
    func drawLabel(_ ctx: BLContext, text: String, bottomLeft: BLPoint) {
        let textInset = UIVector(x: 10, y: 5)
        let renderer = Blend2DRenderer(context: ctx)
        let layout = TextLayout(font: _font, text: text)
        
        let textPoint = bottomLeft.asUIVector - UIVector(x: -textInset.x / 2, y: layout.size.width + textInset.y / 2)
        let boxPoint = bottomLeft.asUIVector - UIVector(x: 0, y: layout.size.height + textInset.y)
        
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
        
        self.init(font: font)
    }
    
    convenience init(text: String) {
        let font = Fonts.defaultFont(size: 12)
        
        self.init(font: font)
        
        self.text = text
    }
    
    init(font: Font) {
        label = Label(textColor: .white, font: font)
        
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
