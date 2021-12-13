import Foundation
import MinWin32
import ImagineUI
import ImagineUI_Win
import Blend2DRenderer
import GeometriaAppLib

class GeometriaWindow: RaytracerApp {
    override func didCloseWindow() {
        super.didCloseWindow()

        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }
}
