import Foundation
import MinWin32
import ImagineUI
import ImagineUI_Win
import Blend2DRenderer
import GeometriaAppLib

class SceneGraphWindow: Blend2DWindowContentType {
    var width: Int { ui.width }
    var height: Int { ui.height }
    var size: UIIntSize { .init(width: width, height: height) }
    var preferredRenderScale: UIVector { .init(x: appRenderScale.x, y: appRenderScale.y) }
    var appRenderScale: BLPoint { ui.appRenderScale }
    weak var delegate: Blend2DWindowContentDelegate?

    var ui: RaytracerGraphApp

    init(size: UIIntSize) {
        ui = RaytracerGraphApp(width: size.width, height: size.height)
        ui.delegate = self
    }

    func show() {
        app.show(content: self)
    }

    func didClose() {
        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }

    func willStartLiveResize() {
        ui.willStartLiveResize()
    }

    func didEndLiveResize() {
        ui.didEndLiveResize()
    }

    func render(context ctx: BLContext, renderScale: UIVector, clipRegion: ClipRegion) {
        ui.render(context: ctx, scale: renderScale.asBLPoint, clipRegion: clipRegion)
    }

    func resize(_ newSize: UIIntSize) {
        ui.resize(width: newSize.width, height: newSize.height)
    }

    func performLayout() {
        ui.performLayout()
    }
    
    func mouseDown(event: MouseEventArgs) {
        ui.mouseDown(event: event)
    }
    func mouseMoved(event: MouseEventArgs) {
        ui.mouseMoved(event: event)
    }
    func mouseUp(event: MouseEventArgs) {
        ui.mouseUp(event: event)
    }
    func mouseScroll(event: MouseEventArgs) {
        ui.mouseScroll(event: event)
    }

    func keyPress(event: KeyPressEventArgs) {
        // 
    }
    
    func keyDown(event: KeyEventArgs) {
        ui.keyDown(event: event)
    }

    func keyUp(event: KeyEventArgs) {
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

    func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(cursor)
    }

    func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves()
    }

    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {
        delegate?.firstResponderChanged(newFirstResponder)
    }
}
