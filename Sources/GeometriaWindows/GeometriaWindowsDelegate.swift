import ImagineUI_Win

class GeometriaWindowsDelegate: ImagineUIAppDelegate {
    var main: Blend2DWindowContentType?

    func appDidLaunch() {
        let main = GeometriaWindow(size: .init(width: 400, height: 300))
        app.show(content: main)

        self.main = main
    }
}
