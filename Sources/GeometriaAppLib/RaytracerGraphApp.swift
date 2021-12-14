import Foundation
import SwiftBlend2D
import ImagineUI
import Text
import Blend2DRenderer

open class RaytracerGraphApp: ImagineUIContentType {
    private var _isResizing: Bool = false
    
    private var ui: RaytracerUI

    private(set) public var size: UIIntSize
    public var width: Int {
        size.width
    }
    public var height: Int {
        size.height
    }

    public var preferredRenderScale: UIVector = .init(repeating: 2)

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

        let uiWrapper = ImagineUIWindowContent(size: size)
        ui = RaytracerUI(uiWrapper: uiWrapper)

        createUI()
    }
    
    func createUI() {
        ControlView.globallyCacheAsBitmap = false
        Label.globallyCacheAsBitmap = false

        let sceneGraph = SceneGraphBuilderComponent()
        ui.addComponent(sceneGraph)
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
    }
    
    public func resize(_ size: UIIntSize) {
        self.size = size

        ui.resize(size)
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

    public func keyPress(event: KeyPressEventArgs) {
        ui.keyPress(event: event)
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
        ui.update(time)
    }
    
    func invalidateAll() {
        delegate?.invalidate(self, bounds: .init(location: .zero, size: UISize(size)))
    }

    public func render(renderer: Renderer, renderScale: UIVector, clipRegion: ClipRegion) {
        ui.render(renderer: renderer, renderScale: renderScale, clipRegion: clipRegion)
    }
}
