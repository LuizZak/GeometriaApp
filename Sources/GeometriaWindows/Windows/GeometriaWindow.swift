import Foundation
import MinWin32
import ImagineUI
import ImagineUI_Win
import Blend2DRenderer
import GeometriaAppLib

class GeometriaWindow: ImagineUIWindowContent {
    var raytracer: RaytracerApp

    override init(size: UIIntSize) {
        raytracer = RaytracerApp(width: size.width, height: size.height)

        super.init(size: size)
        
        raytracer.delegate = self
    }

    override func didClose() {
        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }

    override func willStartLiveResize() {
        raytracer.willStartLiveResize()
    }

    override func didEndLiveResize() {
        raytracer.didEndLiveResize()
    }

    override func render(context ctx: BLContext, renderScale: UIVector, clipRegion: ClipRegion) {
        raytracer.render(context: ctx, scale: renderScale.asBLPoint, clipRegion: clipRegion)
    }

    override func resize(_ newSize: UIIntSize) {
        raytracer.resize(width: newSize.width, height: newSize.height)
    }

    override func performLayout() {
        raytracer.performLayout()
    }
    
    override func mouseDown(event: MouseEventArgs) {
        raytracer.mouseDown(event: event)
    }
    override func mouseMoved(event: MouseEventArgs) {
        raytracer.mouseMoved(event: event)
    }
    override func mouseUp(event: MouseEventArgs) {
        raytracer.mouseUp(event: event)
    }
    override func mouseScroll(event: MouseEventArgs) {
        raytracer.mouseScroll(event: event)
    }

    override func keyPress(event: KeyPressEventArgs) {
        // 
    }
    
    override func keyDown(event: KeyEventArgs) {
        raytracer.keyDown(event: event)
    }

    override func keyUp(event: KeyEventArgs) {
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
}
