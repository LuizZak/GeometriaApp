import MinWin32
import ImagineUI_Win
import GeometriaAppLib

class GeometriaAppDelegate: ImagineUIAppDelegate {
    var main: ImagineUIContentType?

    func appDidLaunch() {
        // NOTE: Disabling caching as it currently causes an assertion in Blend2D
        ControlView.globallyCacheAsBitmap = false
        Label.globallyCacheAsBitmap = false

        GeometriaLogger.logger = WinLoggerWrapper.instance
        ImagineUILogger.logger = WinLoggerWrapper.instance

        let main = GeometriaWindow(size: .init(width: 1000, height: 750))
        //let main = SceneGraphWindow(size: .init(width: 1000, height: 750))
        app.show(content: main)

        self.main = main
    }
}
