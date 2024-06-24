import Foundation
import MinX11
import ImagineUI
import ImagineUI_X11
import Blend2DRenderer
import GeometriaAppLib
import SceneGraphBuilder

class SceneGraphWindow: RaytracerGraphApp {
    override func didCloseWindow() {
        super.didCloseWindow()

        X11Logger.info("\(self): Closed")
        app.requestQuit()
    }
}
