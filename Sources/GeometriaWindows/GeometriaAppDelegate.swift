import MinWin32
import ImagineUI_Win
import GeometriaAppLib

class GeometriaAppDelegate: ImagineUIAppDelegate {
    var main: ImagineUIContentType?

    func appDidLaunch() {
        GeometriaLogger.logger = WinLoggerWrapper()

        //let main = GeometriaWindow(size: .init(width: 1000, height: 750))
        let main = SceneGraphWindow(size: .init(width: 1000, height: 750))
        app.show(content: main)

        self.main = main
    }
}
