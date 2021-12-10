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
        let sceneGraph = SceneGraphTreeComponent(width: 250.0)
        ui.addComponent(sceneGraph)
        let labelsContainer = ui.addComponentInReservedView(StatusLabelsComponent())

        labelsContainer.layout.makeConstraints { make in
            (make.top, make.right, make.bottom) == ui.componentsContainer
            make.right(of: sceneGraph.sidePanel)
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
            camera: Camera(viewportSize: viewportSize)
        )
        
        #else

        let scene = RaymarchingDemoScene3.makeScene()
        
        let renderer = Raymarcher(
            scene: scene,
            camera: Camera(viewportSize: viewportSize)
        )
        
        #endif

        renderer.setupViewportSize(viewportSize)
        
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
    }
}
