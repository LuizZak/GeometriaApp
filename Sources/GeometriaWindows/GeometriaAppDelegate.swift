import ImagineUI_Win

class GeometriaAppDelegate: ImagineUIAppDelegate {
    var main: ImagineUIContentType?

    func appDidLaunch() {
        let main = GeometriaWindow(size: .init(width: 1000, height: 750))
        app.show(content: main)

        self.main = main
    }
}
