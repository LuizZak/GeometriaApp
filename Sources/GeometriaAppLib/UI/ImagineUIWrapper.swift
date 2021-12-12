import Foundation
import ImagineUI
import SwiftBlend2D
import Blend2DRenderer

class ImagineUIWrapper {
    private var lastFrame: TimeInterval = 0
    private var bounds: BLRect
    private var width: Int
    private var height: Int
    private let rendererContext = Blend2DRendererContext()
    private var controlSystem = DefaultControlSystem()
    private var rootViews: [RootView]
    private var currentRedrawRegion: UIRectangle? = nil
    private var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = [] // '.viewBounds', '.layoutGuideBounds', and/or '.constraints'.
    private let _tooltipContainer: RootView = RootView()
    private let _tooltipsManager: TooltipsManager
    
    weak var delegate: Blend2DAppDelegate?
    
    /// The main root view hierarchy where all other UI views are added to.
    let rootView: RootView

    /// If `true`, calls to `render(context:scale:)` can erase the background
    /// of the redraw region prior to rendering.
    var clearRendererOnRedraw: Bool = false
    
    init(size: BLSizeI) {
        width = Int(size.w)
        height = Int(size.h)
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.w), h: Double(size.h)))
        rootViews = []
        rootView = RootView()
        _tooltipsManager = TooltipsManager(container: _tooltipContainer)
        
        controlSystem.delegate = self

        initialize()
    }

    private func initialize() {
        addRootView(rootView)
        addRootView(_tooltipContainer)
        
        _tooltipContainer.passthroughMouseCapture = true
    }
    
    func addRootView(_ view: RootView) {
        view.invalidationDelegate = self
        view.rootControlSystem = controlSystem
        rootViews.append(view)

        if view !== _tooltipContainer && rootViews.contains(_tooltipContainer) {
            // Keep the tooltip container above all other views
            bringRootViewToFront(_tooltipContainer)
        }
    }
    
    func removeRootView(_ view: RootView) {
        view.invalidationDelegate = nil
        view.rootControlSystem = nil
        rootViews.removeAll { $0 === view }
    }
    
    func willStartLiveResize() {
        
    }
    
    func didEndLiveResize() {
        
    }
    
    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        rootView.location = .zero
        rootView.size = .init(width: Double(width), height: Double(height))

        _tooltipContainer.area = .init(x: 0, y: 0, width: Double(width), height: Double(height))
        
        bounds = BLRect(location: .zero, size: BLSize(w: Double(width), h: Double(height)))
        currentRedrawRegion = bounds.asRectangle
        
        for case let window as Window in rootViews where window.windowState == .maximized {
            window.setNeedsLayout()
        }
    }
    
    func invalidateScreen() {
        currentRedrawRegion = bounds.asRectangle
        delegate?.invalidate(bounds: bounds.asRectangle)
    }
    
    func update(_ time: TimeInterval) {
        // Fixed-frame update
        let delta = time - lastFrame
        lastFrame = time
        Scheduler.instance.onFixedFrame(delta)
    }
    
    func performLayout() {
        // Layout loop
        for rootView in rootViews {
            rootView.performLayout()
        }
    }
    
    func render(context ctx: BLContext, scale: BLPoint) {
        guard let rect = currentRedrawRegion else {
            return
        }
        
        ctx.scale(by: scale)

        let redrawRegion = BLRegion(rectangle: BLRectI(rounding: rect.asBLRect))

        if clearRendererOnRedraw {
            ctx.setFillStyle(BLRgba32.cornflowerBlue)
            ctx.fillRect(rect.asBLRect)
        }

        let renderer = Blend2DRenderer(context: ctx)
        
        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: Blend2DClipRegion(region: redrawRegion))
        }
        
        // Debug render
        for rootView in rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, in: renderer)
        }
    }
    
    func mouseDown(event: MouseEventArgs) {
        controlSystem.onMouseDown(event)
    }
    
    func mouseMoved(event: MouseEventArgs) {
        controlSystem.onMouseMove(event)
    }
    
    func mouseUp(event: MouseEventArgs) {
        controlSystem.onMouseUp(event)
    }
    
    func mouseScroll(event: MouseEventArgs) {
        controlSystem.onMouseWheel(event)
    }
    
    func keyDown(event: KeyEventArgs) {
        controlSystem.onKeyDown(event)
    }
    
    func keyUp(event: KeyEventArgs) {
        controlSystem.onKeyUp(event)
    }
}

extension ImagineUIWrapper: DefaultControlSystemDelegate {
    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {

    }

    func bringRootViewToFront(_ rootView: RootView) {
        if !(rootView is Window) {
            return
        }

        rootViews.removeAll(where: { $0 == rootView })

        // Keep the tooltip container above all other views
        if rootView !== _tooltipContainer, let index = rootViews.firstIndex(of: _tooltipContainer) {
            rootViews.insert(rootView, at: index)
        } else {
            rootViews.append(rootView)
        }

        rootView.invalidate()
    }
    
    func controlViewUnder(point: UIVector, enabledOnly: Bool) -> ControlView? {
        for rootView in rootViews.reversed() {
            let converted = rootView.convertFromScreen(point)
            if let view = rootView.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }
        
        return nil
    }
    
    func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(cursor)
    }
    
    func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves()
    }

    func showTooltip(_ tooltip: Tooltip, view: View, location: PreferredTooltipLocation) {
        _tooltipsManager.showTooltip(tooltip, view: view, location: location)
    }

    func updateTooltip(_ tooltip: Tooltip) {
        _tooltipsManager.updateTooltip(tooltip)
    }

    func hideTooltip() {
        _tooltipsManager.hideTooltip()
    }

    func updateTooltipCursorLocation(_ location: UIPoint) {
        _tooltipsManager.updateTooltipCursorLocation(location)
    }
}

extension ImagineUIWrapper: RootViewRedrawInvalidationDelegate {
    func rootViewInvalidatedLayout(_ rootView: RootView) {
        delegate?.needsLayout(rootView)
    }

    func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        guard let intersectedRect = rect.intersection(bounds.asRectangle) else {
            return
        }
        
        if let current = currentRedrawRegion {
            currentRedrawRegion = current.union(intersectedRect)
        } else {
            currentRedrawRegion = intersectedRect
        }
        
        delegate?.invalidate(bounds: intersectedRect)
    }
}

extension ImagineUIWrapper: WindowDelegate {
    func windowWantsToClose(_ window: Window) {
        if let index = rootViews.firstIndex(of: window) {
            rootViews.remove(at: index)
            invalidateScreen()
        }
    }
    
    func windowWantsToMaximize(_ window: Window) {
        switch window.windowState {
        case .maximized:
            window.setWindowState(.normal)
            
        case .normal, .minimized:
            window.setWindowState(.maximized)
        }
    }
    
    func windowWantsToMinimize(_ window: Window) {
        window.setWindowState(.minimized)
    }
    
    func windowSizeForFullscreen(_ window: Window) -> UISize {
        return bounds.asRectangle.size
    }
}
