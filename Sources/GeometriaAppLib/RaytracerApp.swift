import Foundation
import SwiftBlend2D
import ImagineUI
import Text
import Blend2DRenderer

private let instructions: String = """
"""

open class RaytracerApp: RaytracerUI {
    private var _updateTimer: SchedulerTimerType?
    private var _isResizing: Bool = false
    private var _mouseLocation: BLPointI = .zero
    
    private var threadCount: Int = 12
    
    // Components
    private let statusMessages: StatusMessageStackComponent = StatusMessageStackComponent()
    private let statusLabels: StatusLabelsComponent = StatusLabelsComponent()
    private let uiProjection: UIProjectionComponent = UIProjectionComponent()
    
    var rendererCoordinator: RendererCoordinator?
    var renderer: RendererType?
    var buffer: Blend2DBufferWriter?
    
    public var time: TimeInterval = 0

    public private(set) var dpiScalingMode: DpiScalingMode = .useDpiScale {
        didSet {
            statusLabels.updateDpiScalingModeLabel(
                dpiScalingMode,
                currentScale: delegate?.windowDpiScalingFactor(self) ?? 1.0
            )

            guard let delegate, dpiScalingMode != oldValue else {
                return
            }

            if delegate.windowDpiScalingFactor(self) != 1.0 {
                restartRendering()
            }
        }
    }
    
    public override init(size: UIIntSize) {
        super.init(size: size)

        time = 0
        
        backgroundColor = nil

        restartRendering()
        createUI()
    }

    deinit {
        _updateTimer?.invalidate()
    }
    
    func createUI() {
        // UI projection
        addComponent(uiProjection)
        
        // Scene graph tree view
        let sceneGraph = SceneGraphTreeComponent(width: 250.0)
        sceneGraph.treeComponentDelegate = self
        addComponent(sceneGraph)

        // Status labels
        let labelsContainer = addComponentInReservedView(statusLabels)
        labelsContainer.layout.makeConstraints { make in
            (make.top, make.right, make.bottom) == componentsContainer
            make.right(of: sceneGraph.sidePanel)
        }

        // Status messages
        addComponent(statusMessages)
    }

    open override func didCloseWindow() {
        super.didCloseWindow()

        rendererCoordinator?.cancel()
    }
    
    open override func willStartLiveResize() {
        super.willStartLiveResize()
        
        _isResizing = true
    }
    
    open override func didEndLiveResize() {
        super.didEndLiveResize()
        
        _isResizing = false
        
        restartRendering()
    }
    
    open override func resize(_ size: UIIntSize) {
        super.resize(size)

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

        statusLabels.updateDpiScalingModeLabel(
            dpiScalingMode,
            currentScale: delegate?.windowDpiScalingFactor(self) ?? 1.0
        )
    }
    
    func recreateRenderer() {
        guard width > 0 && height > 0 else {
            return
        }
        
        let scaleFactor: Double

        switch dpiScalingMode {
        case .useDpiScale:
            scaleFactor = delegate?.windowDpiScalingFactor(self) ?? 1.0
        case .ignoreDpi:
            scaleFactor = 1.0
        }
        
        let image = BLImage(
            width: Int(Double(width) * scaleFactor),
            height: Int(Double(height) * scaleFactor),
            format: .prgb32
        )
        
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
        //let batcher = SinglePixelBatcher(pixel: .init(x: 607, y: 514)) // Raytracing bouncing past floor plane causing shadow issues in raytracing demo scene 1
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

        let camera = Camera(
            viewportSize: viewportSize,
            viewportCenter: .init(x: 0.0, y: 0, z: 90.0)
        )

        #if true
        
        let scene = RaytracingDemoScene1.makeScene()
        
        let renderer = Raytracer(
            scene: scene,
            camera: camera
        )
        
        #else

        let scene = RaymarchingHyperplanePolyhedronScene.makeScene()
        
        let renderer = Raymarcher(
            scene: scene,
            camera: camera
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

        rendererCoordinatorChanged(rendererCoordinator)
        rendererChanged(renderer)
        
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

    func toggleDpiScalingMode() {
        switch dpiScalingMode {
        case .ignoreDpi:
            dpiScalingMode = .useDpiScale
        case .useDpiScale:
            dpiScalingMode = .ignoreDpi
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
    
    open override func keyDown(event: KeyEventArgs) {
        if event.keyCode == .space {
            togglePause()
            event.handled = true
        }
        if event.keyCode == .r {
            restartRendering()
            event.handled = true
        }
        if event.keyCode == .s {
            toggleDpiScalingMode()
            event.handled = true
        }
        if event.keyCode == .o {
            debugAtMousePointer()
            event.handled = true
        }
        
        if !event.handled {
            super.keyDown(event: event)
        }
    }
    
    open override func mouseMoved(event: MouseEventArgs) {
        _mouseLocation = event.location.asBLPointI

        super.mouseMoved(event: event)
        
        invalidateAll()
    }
    
    // MARK: -
    
    open override func update(_ time: TimeInterval) {
        if let renderer = rendererCoordinator, renderer.state == .running {
            invalidateAll()
        }
        
        super.update(time)
    }
    
    func invalidateAll() {
        delegate?.invalidate(self, bounds: .init(location: .zero, size: UISize(size)))
    }
    
    open override func render(renderer: Renderer, renderScale: UIVector, clipRegion: ClipRegionType) {
        renderer.clear(.black)

        if let buffer = buffer {
            buffer.usingImage { img in
                let img = Blend2DImage(image: img)

                if renderScale == .one || dpiScalingMode == .useDpiScale {
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
        }
        
        super.render(renderer: renderer, renderScale: renderScale, clipRegion: clipRegion)
    }

    /// Specifies how DPI scaling of underlying OS window affects the size of the
    /// backbuffer image being rendered upon.
    public enum DpiScalingMode {
        /// Ignore DPI scaling and use logical size of content window for backbuffer.
        /// May lead to scaling artifacts when DPI scaling is not 1:1.
        case ignoreDpi

        /// Scale logical size of content window by DPI to scale the backbuffer
        /// accordingly.
        case useDpiScale
    }
}

extension RaytracerApp: SceneGraphTreeComponentDelegate {
    func sceneGraphTreeComponent(
        _ component: SceneGraphTreeComponent,
        didChangeSelection selection: Set<Element.Id>
    ) {

        uiProjection.geometryIdsToShow = selection
    }
}
