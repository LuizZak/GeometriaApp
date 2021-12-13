import Foundation
import MinWin32
import ImagineUI
import ImagineUI_Win
import Blend2DRenderer
import GeometriaAppLib

class SceneGraphWindow: RaytracerGraphApp {
    override func didCloseWindow() {
        super.didCloseWindow()

        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }
}
