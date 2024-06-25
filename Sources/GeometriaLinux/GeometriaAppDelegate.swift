import ImagineUI_X11

class GeometriaAppDelegate: ImagineUIAppDelegate {
    var main: ImagineUIContentType?

    func appDidLaunch() {
        ControlView.globallyCacheAsBitmap = false

        let main = SceneGraphWindow(size: .init(width: 1000, height: 750))
        app.show(content: main)

        self.main = main
    }
}
