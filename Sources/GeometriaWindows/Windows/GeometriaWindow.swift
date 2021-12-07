import Foundation
import MinWin32
import ImagineUI
import ImagineUI_Win
import Blend2DRenderer
import GeometriaAppLib

class GeometriaWindow: Blend2DWindowContentType {
    var width: Int { raytracer.width }
    var height: Int { raytracer.height }
    var size: UIIntSize { .init(width: width, height: height) }
    var preferredRenderScale: UIVector { .init(x: appRenderScale.x, y: appRenderScale.y) }
    var appRenderScale: BLPoint { raytracer.appRenderScale }
    weak var delegate: Blend2DWindowContentDelegate?

    var raytracer: RaytracerApp

    init(size: UIIntSize) {
        raytracer = RaytracerApp(width: size.width, height: size.height)
        raytracer.delegate = self
    }

    func show() {
        app.show(content: self)
    }

    func didClose() {
        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }

    func willStartLiveResize() {
        raytracer.willStartLiveResize()
    }

    func didEndLiveResize() {
        raytracer.didEndLiveResize()
    }

    func render(context ctx: BLContext, renderScale: UIVector, clipRegion: ClipRegion) {
        raytracer.render(context: ctx, scale: renderScale.asBLPoint, clipRegion: clipRegion)
    }

    func resize(_ newSize: UIIntSize) {
        raytracer.resize(width: newSize.width, height: newSize.height)
    }

    func performLayout() {
        raytracer.performLayout()
    }
    
    func mouseDown(event: MouseEventArgs) {
        raytracer.mouseDown(event: event)
    }
    func mouseMoved(event: MouseEventArgs) {
        raytracer.mouseMoved(event: event)
    }
    func mouseUp(event: MouseEventArgs) {
        raytracer.mouseUp(event: event)
    }
    func mouseScroll(event: MouseEventArgs) {
        raytracer.mouseScroll(event: event)
    }

    func keyPress(event: KeyPressEventArgs) {
        // 
    }
    
    func keyDown(event: KeyEventArgs) {
        raytracer.keyDown(event: event)
    }

    func keyUp(event: KeyEventArgs) {
        raytracer.keyUp(event: event)
    }
}

extension GeometriaWindow: Blend2DAppDelegate {
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
