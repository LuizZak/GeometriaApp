import MinX11
import GeometriaAppLib

class GeometriaWindow: RaytracerApp {
    override func didCloseWindow() {
        super.didCloseWindow()

        X11Logger.info("\(self): Closed")
        app.requestQuit()
    }
}
