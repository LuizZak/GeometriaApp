import Foundation
import MinX11
import ImagineUI
import ImagineUI_X11
import Blend2DRenderer
import GeometriaAppLib

class GeometriaWindow: ImagineUIContentType {
    var width: Int { raytracer.width }
    var height: Int { raytracer.height }
    var size: UIIntSize { .init(width: width, height: height) }
    var preferredRenderScale: UIVector { .init(x: appRenderScale.x, y: appRenderScale.y) }
    var appRenderScale: BLPoint { raytracer.appRenderScale }
    weak var delegate: ImagineUIContentDelegate?

    var raytracer: RaytracerApp

    init(size: UIIntSize) {
        raytracer = RaytracerApp(width: size.width, height: size.height)
        raytracer.delegate = self
    }

    func show() {
        app.show(content: self)
    }

    func didClose() {
        X11Logger.info("\(self): Closed")
        app.requestQuit()
    }

    func willStartLiveResize() {
        raytracer.willStartLiveResize()
    }

    func didEndLiveResize() {
        raytracer.didEndLiveResize()
    }

    func mouseLeave() {

    }

    func didCloseWindow() {

    }

    func render(renderer: any Rendering.Renderer, renderScale: Geometry.UIVector, clipRegion: any Rendering.ClipRegionType) {
        guard let renderer = renderer as? Blend2DRenderer else {
            fatalError("Expected renderer to be a BLContext renderer")
        }

        render(context: renderer.blend2DContext, renderScale: renderScale, clipRegion: clipRegion)
    }

    func render(context ctx: BLContext, renderScale: UIVector, clipRegion: any ClipRegionType) {
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
        raytracer.keyPress(event: event)
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
        delegate?.needsLayout(self, view)
    }

    func invalidate(bounds: UIRectangle) {
        delegate?.invalidate(self, bounds: bounds)
    }

    func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(self, cursor: cursor)
    }

    func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves(self)
    }

    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {
        delegate?.firstResponderChanged(self, newFirstResponder)
    }
}
