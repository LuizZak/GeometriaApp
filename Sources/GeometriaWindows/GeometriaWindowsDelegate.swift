import ImagineUI_Win

class GeometriaWindowsDelegate: ImagineUIAppDelegate {
    var main: Blend2DWindowContentType?

    func appDidLaunch() throws {
        let main = DirectXWindow(size: .init(width: 1000, height: 750))
        main.show()

        /*
        let main = GeometriaWindow(size: .init(width: 1000, height: 750))
        app.show(content: main)

        self.main = main
        */
    }
}
