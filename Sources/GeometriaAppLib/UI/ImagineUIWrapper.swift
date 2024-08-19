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
    private var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = [] // '.viewBounds', '.layoutGuideBounds', and/or '.constraints'.

    private var allRootViews: [RootView] {
        rootViews + [tooltipRootView]
    }

    /// A root view for tooltips that must always be kept above other root views.
    private let tooltipRootView = RootView()
    private let tooltipManager: ImagineUITooltipsManager

    /// The main root view hierarchy where all other UI views are added to.
    let rootView = RootView()

    weak var delegate: Blend2DAppDelegate?

    init(size: BLSizeI) {
        width = Int(size.w)
        height = Int(size.h)
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.w), h: Double(size.h)))
        rootViews = []
        tooltipManager = ImagineUITooltipsManager(container: tooltipRootView)
        controlSystem.delegate = self

        addRootView(rootView)
        configureRootView(tooltipRootView)
        tooltipRootView.passthroughMouseCapture = true
    }

    func configureRootView(_ view: RootView) {
        view.invalidationDelegate = self
        view.rootControlSystem = controlSystem
    }

    func addRootView(_ view: RootView) {
        configureRootView(view)
        rootViews.append(view)
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

        func _resizeRootView(_ view: RootView) {
            view.location = .zero
            view.size = .init(width: Double(width), height: Double(height))
        }

        _resizeRootView(rootView)
        _resizeRootView(tooltipRootView)

        bounds = BLRect(location: .zero, size: BLSize(w: Double(width), h: Double(height)))

        for case let window as Window in allRootViews where window.windowState == .maximized {
            window.setNeedsLayout()
        }
    }

    func invalidateScreen() {
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
        for rootView in allRootViews {
            rootView.performLayout()
        }
    }

    func render(renderer: any Renderer, scale: BLPoint, clipRegion: any ClipRegionType) {
        renderer.scale(by: scale.asUIVector)

        // Redraw loop
        for rootView in allRootViews {
            rootView.renderRecursive(in: renderer, screenRegion: clipRegion)
        }

        // Debug render
        for rootView in allRootViews {
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

    func keyPress(event: KeyPressEventArgs) -> Bool {
        controlSystem.onKeyPress(event)
    }

    func keyUp(event: KeyEventArgs) {
        controlSystem.onKeyUp(event)
    }
}

extension ImagineUIWrapper: BaseControlSystemDelegate {
    func viewForDialog(_ dialog: any UIDialog, location: UIDialogInitialLocation) -> View {
        rootView
    }

    func tooltipsManager() -> (any TooltipsManagerType)? {
        tooltipManager
    }

    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {

    }

    func bringRootViewToFront(_ rootView: RootView) {
        rootViews.removeAll(where: { $0 == rootView })
        rootViews.append(rootView)

        rootView.invalidate()
    }

    func controlViewUnder(point: UIVector, enabledOnly: Bool) -> ControlView? {
        for window in allRootViews.reversed() {
            let converted = window.convertFromScreen(point)
            if let view = window.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }

        return nil
    }

    func controlViewUnder(
        point: UIVector,
        controlKinds: ControlKinds
    ) -> ControlView? {
        for window in allRootViews.reversed() {
            let converted = window.convertFromScreen(point)
            let enabledOnly = !controlKinds.contains(.disabledFlag)
            if let view = window.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }

        return nil
    }

    func controlViewUnder(
        point: UIVector,
        forEventRequest eventRequest: any EventRequest,
        controlKinds: ControlKinds
    ) -> ControlView? {
        for window in allRootViews.reversed() {
            let converted = window.convertFromScreen(point)
            let enabledOnly = !controlKinds.contains(.disabledFlag)
            if let view = window.hitTestControl(converted, forEventRequest: eventRequest, enabledOnly: enabledOnly) {
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
}

extension ImagineUIWrapper: RootViewRedrawInvalidationDelegate {
    func rootViewInvalidatedLayout(_ rootView: RootView) {
        delegate?.needsLayout(rootView)
    }

    func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        guard let intersectedRect = rect.intersection(bounds.asRectangle) else {
            return
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
