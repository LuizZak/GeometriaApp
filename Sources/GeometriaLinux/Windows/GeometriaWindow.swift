import Foundation
import MinX11
import ImagineUI
import ImagineUI_X11
import Blend2DRenderer
import GeometriaAppLib

class GeometriaWindow: RaytracerApp {
    override func didCloseWindow() {
        super.didCloseWindow()

        X11Logger.info("\(self): Closed")
        app.requestQuit()
    }
}
