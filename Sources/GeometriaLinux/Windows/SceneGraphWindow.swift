import MinX11
import SceneGraphBuilder

class SceneGraphWindow: RaytracerGraphApp {
    override func didCloseWindow() {
        super.didCloseWindow()

        X11Logger.info("\(self): Closed")
        app.requestQuit()
    }
}
