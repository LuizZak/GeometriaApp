import Foundation
import MinWin32
import ImagineUI
import ImagineUI_Win
import Blend2DRenderer
import GeometriaAppLib

class SceneGraphWindow: ImagineUIWindowContent {
    var ui: RaytracerGraphApp

    override init(size: UIIntSize) {
        ui = RaytracerGraphApp(width: size.width, height: size.height)
        
        super.init(size: size)

        ui.delegate = self
    }

    override func didClose() {
        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }

    override func willStartLiveResize() {
        ui.willStartLiveResize()
    }

    override func didEndLiveResize() {
        ui.didEndLiveResize()
    }

    override func render(context ctx: BLContext, renderScale: UIVector, clipRegion: ClipRegion) {
        ui.render(context: ctx, scale: renderScale.asBLPoint, clipRegion: clipRegion)
    }

    override func resize(_ newSize: UIIntSize) {
        ui.resize(width: newSize.width, height: newSize.height)
    }

    override func performLayout() {
        ui.performLayout()
    }
    
    override func mouseDown(event: MouseEventArgs) {
        ui.mouseDown(event: event)
    }
    override func mouseMoved(event: MouseEventArgs) {
        ui.mouseMoved(event: event)
    }
    override func mouseUp(event: MouseEventArgs) {
        ui.mouseUp(event: event)
    }
    override func mouseScroll(event: MouseEventArgs) {
        ui.mouseScroll(event: event)
    }

    override func keyPress(event: KeyPressEventArgs) {
        // 
    }
    
    override func keyDown(event: KeyEventArgs) {
        ui.keyDown(event: event)
    }

    override func keyUp(event: KeyEventArgs) {
        ui.keyUp(event: event)
    }
}

extension SceneGraphWindow: Blend2DAppDelegate {
    func needsLayout(_ view: View) {
        delegate?.needsLayout(view)
    }

    func invalidate(bounds: UIRectangle) {
        delegate?.invalidate(bounds: bounds)
    }
}
