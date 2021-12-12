import Foundation
import SwiftBlend2D
import ImagineUI
import Text
import Blend2DRenderer

public class RaytracerGraphApp: Blend2DApp {
    private var _isResizing: Bool = false
    
    private var ui: RaytracerUI
    
    public var width: Int
    public var height: Int
    public var appRenderScale: BLPoint = .init(repeating: 2)
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

        let uiWrapper = ImagineUIWrapper(size: BLSizeI(w: Int32(width), h: Int32(height)))
        uiWrapper.clearRendererOnRedraw = true
        ui = RaytracerUI(uiWrapper: uiWrapper)

        createUI()
    }
    
    func createUI() {
        ControlView.globallyCacheAsBitmap = false

        let sceneGraph = SceneGraphBuilderComponent()
        ui.addComponent(sceneGraph)
    }
    
    public func willStartLiveResize() {
        ui.willStartLiveResize()
        
        _isResizing = true
    }
    
    public func didEndLiveResize() {
        ui.didEndLiveResize()
        
        _isResizing = false
    }
    
    public func resize(width: Int, height: Int) {
        self.width = width
        self.height = height

        ui.resize(width: width, height: height)
    }
    
    // MARK: - UI
    
    public func performLayout() {
        ui.performLayout()
    }
    
    public func keyDown(event: KeyEventArgs) {
        ui.keyDown(event: event)
    }
    
    public func keyUp(event: KeyEventArgs) {
        ui.keyUp(event: event)
    }
    
    public func mouseScroll(event: MouseEventArgs) {
        ui.mouseScroll(event: event)
    }
    
    public func mouseMoved(event: MouseEventArgs) {
        ui.mouseMoved(event: event)
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
        
        ui.update(time)
    }
    
    func invalidateAll() {
        delegate?.invalidate(bounds: .init(x: 0, y: 0, width: Double(width), height: Double(height)))
    }
    
    public func render(context ctx: BLContext, scale: BLPoint, clipRegion: ClipRegion) {
        let bounds = clipRegion.bounds()
        ctx.setFillStyle(BLRgba32.black)
        ctx.fillRect(bounds.asBLRect)

        ui.render(context: ctx, scale: scale)
    }
}
