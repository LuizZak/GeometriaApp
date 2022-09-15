import Foundation
import SwiftBlend2D
import ImagineUI
import Text
import Blend2DRenderer

private let instructions: String = """
"""

open class RaytracerApp: ImagineUIContentType {
    private var _updateTimer: SchedulerTimerType?
    private var _isResizing: Bool = false
    private var _mouseLocation: BLPointI = .zero
    
    private var threadCount: Int = 12
    
    private var ui: RaytracerUI
    private let statusMessages: StatusMessageStack = StatusMessageStack()
    
    var rendererCoordinator: RendererCoordinator?
    var renderer: RendererType?
    var buffer: Blend2DBufferWriter?
    
    private(set) public var size: UIIntSize
    public var width: Int {
        size.width
    }
    public var height: Int {
        size.height
    }
    
    public var preferredRenderScale: UIVector = .one
    public var time: TimeInterval = 0
    
    public weak var delegate: ImagineUIContentDelegate? {
        get {
            ui.delegate
        }
        set {
            ui.delegate = newValue
        }
    }
    
    public init(size: UIIntSize) {
        self.size = size
        time = 0
        
        let uiWrapper = ImagineUIWindowContent(size: size)
        uiWrapper.backgroundColor = nil
        ui = RaytracerUI(uiWrapper: uiWrapper)

        restartRendering()
        createUI()
    }

    deinit {
        _updateTimer?.invalidate()
    }
    
    func createUI() {
        let uiProjection = UIProjectionComponent()
        ui.addComponent(uiProjection)
        
        let sceneGraph = SceneGraphTreeComponent(width: 250.0)
        ui.addComponent(sceneGraph)
        
        let labelsContainer = ui.addComponentInReservedView(StatusLabelsComponent())
        labelsContainer.layout.makeConstraints { make in
            (make.top, make.right, make.bottom) == ui.componentsContainer
            make.right(of: sceneGraph.sidePanel)
        }

        ui.addComponent(statusMessages)
    }

    open func didCloseWindow() {
        
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
    
    public func resize(_ size: UIIntSize) {
        self.size = size

        ui.resize(size)

        restartRendering()
    }
    
    func restartRendering() {
        _updateTimer = Scheduler.instance.scheduleTimer(interval: 1 / 60.0, repeats: true) { [weak self] in
            self?.update(UISettings.timeInSeconds())
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

        // NOTE: Following coordinates assume a window size of 1000 x 750.
//        let batcher = SinglePixelBatcher(pixel: .init(x: 173, y: 171)) // Transparent sphere - bottom-left center of refraction 'anomaly'
//        let batcher = SinglePixelBatcher(pixel: .init(x: 261, y: 173)) // Reflection of transparent sphere on right sphere
//        let batcher = SinglePixelBatcher(pixel: .init(x: 273, y: 150)) // Refractive cylinder
//        let batcher = SinglePixelBatcher(pixel: .init(x: 172, y: 156)) // Bug in refractive bouncing in left sphere
//        let batcher = SinglePixelBatcher(pixel: .init(x: 255, y: 224)) // Bug in refractive bouncing in cylinder's base
//        let batcher = SinglePixelBatcher(pixel: .init(x: 177, y: 202)) // Top of cube-cylinder subtraction demo scene
//        let batcher = SinglePixelBatcher(pixel: .init(x: 180, y: 195)) // Left of cube-cylinder subtraction demo scene bug
        //let batcher = SinglePixelBatcher(pixel: .init(x: 500, y: 493)) // Pass-through of bottom of cylinder subtracted from a cube
        //let batcher = SinglePixelBatcher(pixel: .init(x: 111, y: 174)) // Glitch in shadow in background box in raytracing Demo Scene 1
        //let batcher = SinglePixelBatcher(pixel: .init(x: 500, y: 549)) // Ray missing target plane in raytracing Demo Scene 1
        //let batcher = SinglePixelBatcher(pixel: .init(x: 450, y: 400)) // Issue with intersection of hyperplanes in Tetrahedron scene
        //let batcher = SinglePixelBatcher(pixel: .init(x: 445, y: 375)) // Issue with refraction in Tetrahedron scene
        //let batcher = SinglePixelBatcher(pixel: .init(x: 350, y: 470)) // Issue with AABB shadows in raytracing demo scene 1
        //let batcher = SinglePixelBatcher(pixel: .init(x: 425, y: 570)) // Issue with target-textured plane shadows in raytracing demo scene 1
        //let batcher = SinglePixelBatcher(pixel: .init(x: 430, y: 510)) // Expected shadow path for translucent sphere in raytracing demo scene 1
        //let batcher = SinglePixelBatcher(pixel: .init(x: 455, y: 507)) // Buggy shadow in raytraced rotated cylinder in RaytracingDemoScene4
        //let batcher = SinglePixelBatcher(pixel: .init(x: 717, y: 445)) // Raytracing penetration past disk object in reflection of right sphere on raytracing demo scene 1
        //*
        let batcher = TiledBatcher(
            splitting: viewportSize,
            estimatedThreadCount: threadCount * 2,
            shuffleOrder: true
        )
        // */
//        let batcher = SieveBatcher()
//        let batcher = LinearBatcher()
        
        // TODO: Derive camera configuration from the demo scene builders.

        #if true
        
        let scene = RaytracingDemoScene1.makeScene()
        
        let renderer = Raytracer(
            scene: scene,
            camera: Camera(viewportSize: viewportSize)
        )
        
        #else

        let scene = RaymarchingHyperplanePolyhedronScene.makeScene()
        
        let renderer = Raymarcher(
            scene: scene,
            camera: Camera(viewportSize: viewportSize)
        )
        // renderer.renderMode = .marchSteps()
        
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
        
        rendererCoordinator?.stateDidChange.addListener(weakOwner: self) { [weak self] (change) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if change.newValue == .finished {
                    self.invalidateAll()
                }
            }
        }
        rendererCoordinator?.initialize()
        rendererCoordinator?.start()

        self.renderer = renderer
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

    func debugAtMousePointer() {
        guard let rendererCoordinator = rendererCoordinator else {
            return
        }

        guard rendererCoordinator.state != .running else {
            statusMessages.showMessage(
                "Cannot debug pixels during rendering (please pause with space bar first)"
            )

            return
        }

        guard let renderer = renderer else {
            return
        }
        guard let clipboard = globalTextClipboard else {
            return
        }

        clipboard.setText("Abcde")

        let pixel = _mouseLocation.asUIIntPoint
        guard pixel >= .zero && pixel < size.asUIIntPoint else {
            return
        }

        let oldIsMultithreaded = renderer.isMultiThreaded
        renderer.isMultiThreaded = false
        renderer.beginDebug()
        
        _ = renderer.render(pixelAt: pixel)
        
        renderer.endDebug(target:
            ClipboardProcessingPrinterTarget(
                clipboard: clipboard
            )
        )

        renderer.isMultiThreaded = oldIsMultithreaded

        statusMessages.showMessage(
            "Copied Processing debug scene for pixel (\(pixel.x), \(pixel.y)) to clipboard."
        )
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
        if event.keyCode == .o {
            debugAtMousePointer()
            event.handled = true
        }
        
        if !event.handled {
            ui.keyDown(event: event)
        }
    }
    
    public func keyUp(event: KeyEventArgs) {
        ui.keyUp(event: event)
    }

    public func keyPress(event: KeyPressEventArgs) {
        ui.keyPress(event: event)
    }
    
    public func mouseScroll(event: MouseEventArgs) {
        ui.mouseScroll(event: event)
    }
    
    public func mouseMoved(event: MouseEventArgs) {
        _mouseLocation = event.location.asBLPointI

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
        delegate?.invalidate(self, bounds: .init(location: .zero, size: UISize(size)))
    }
    
    public func render(renderer: Renderer, renderScale: UIVector, clipRegion: ClipRegionType) {
        if let buffer = buffer {
            buffer.usingImage { img in
                let img = Blend2DImage(image: img)

                if renderScale == .one {
                    renderer.drawImage(img, at: .zero)
                } else {
                    let rect = UIRectangle(
                        x: 0,
                        y: 0,
                        width: Double(width) * renderScale.x,
                        height: Double(height) * renderScale.y
                    )
                    
                    renderer.drawImageScaled(img, area: rect)
                }
            }
        } else {
            renderer.clear(.white)
        }
        
        ui.render(renderer: renderer, renderScale: renderScale, clipRegion: clipRegion)
    }
}
