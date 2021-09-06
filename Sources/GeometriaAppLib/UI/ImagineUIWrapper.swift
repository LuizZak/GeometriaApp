import Foundation
import AppKit
import ImagineUI
import SwiftBlend2D

class ImagineUIWrapper {
    private var lastFrame: TimeInterval = 0
    private var bounds: BLRect
    private var width: Int
    private var height: Int
    private let rendererContext = Blend2DRendererContext()
    private var controlSystem = DefaultControlSystem()
    private var rootViews: [RootView]
    private var currentRedrawRegion: Rectangle? = nil
    private var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = []
    
    var sampleRenderScale: BLPoint = .one
    
    let rootView = RootView()
    
    weak var delegate: Blend2DSampleDelegate?
    
    init(size: BLSizeI) {
        width = Int(size.w)
        height = Int(size.h)
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.w), h: Double(size.h)))
        rootViews = []
        controlSystem.delegate = self
        UISettings.scale = sampleRenderScale.asVector2
        globalTextClipboard = MacOSTextClipboard()
        
        try! UISettings.initialize(.init(fontManager: Blend2DFontManager(),
                                         defaultFontPath: Fonts.fontFilePath))
        
        addRootView(rootView)
    }
    
    func addRootView(_ view: RootView) {
        view.invalidationDelegate = self
        rootViews.append(view)
    }
    
    func removeRootView(_ view: RootView) {
        view.invalidationDelegate = nil
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
        rootView.size = .init(.init(x: width, y: height))
        
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
        
        performLayout()
    }
    
    func performLayout() {
        // Layout loop
        for rootView in rootViews {
            rootView.performLayout()
        }
    }
    
    func render(context ctx: BLContext) {
        guard let rect = currentRedrawRegion else {
            return
        }
        
        ctx.scale(by: sampleRenderScale)
//        ctx.setFillStyle(BLRgba32.cornflowerBlue)
        
        let redrawRegion = BLRegion(rectangle: BLRectI(rounding: rect.asBLRect))
        
//        ctx.fillRect(rect.asBLRect)
        
        let renderer = Blend2DRenderer(context: ctx)
        
        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: Blend2DClipRegion(region: redrawRegion))
        }
        
        // Debug render
        for rootView in rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, to: ctx)
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
    func bringRootViewToFront(_ rootView: RootView) {
        rootViews.removeAll(where: { $0 == rootView })
        rootViews.append(rootView)
        
        rootView.invalidate()
    }
    
    func controlViewUnder(point: Vector, enabledOnly: Bool) -> ControlView? {
        for window in rootViews.reversed() {
            let converted = window.convertFromScreen(point)
            if let view = window.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }
        
        return nil
    }
    
    func setMouseCursor(_ cursor: MouseCursorKind) {
        switch cursor {
        case .iBeam:
            NSCursor.iBeam.set()
        case .arrow:
            NSCursor.arrow.set()
        case .resizeLeftRight:
            NSCursor.resizeLeftRight.set()
        case .resizeUpDown:
            NSCursor.resizeUpDown.set()
        case let .custom(imagePath, hotspot):
            let cursor = NSCursor(image: NSImage(byReferencingFile: imagePath)!,
                                  hotSpot: NSPoint(x: hotspot.x, y: hotspot.y))
            
            cursor.set()
        }
    }
    
    func setMouseHiddenUntilMouseMoves() {
        NSCursor.setHiddenUntilMouseMoves(true)
    }
}

extension ImagineUIWrapper: RootViewRedrawInvalidationDelegate {
    func rootView(_ rootView: RootView, invalidateRect rect: Rectangle) {
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
    
    func windowSizeForFullscreen(_ window: Window) -> Size {
        return bounds.asRectangle.size
    }
}

class MacOSTextClipboard: TextClipboard {
    func getText() -> String? {
        NSPasteboard.general.string(forType: .string)
    }
    
    func setText(_ text: String) {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    func containsText() -> Bool {
        return getText() != nil
    }
}
