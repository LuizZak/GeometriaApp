import ImagineUI_Win

class GeometriaWindowsDelegate: ImagineUIAppDelegate {
    var main: Blend2DWindowContentType?

    func appDidLaunch() {
        let main = GeometriaWindow(size: .init(width: 1000, height: 750))
        app.show(content: main)

        self.main = main
    }
}
