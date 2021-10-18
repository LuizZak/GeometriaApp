import ImagineUI_Win
import MinWin32

class GeometriaWindowsDelegate: ImagineUIAppDelegate {
    var main: Blend2DWindowContentType?
    var window: DirectXWindow?

    func appDidLaunch() throws {
        let settings = Win32Window.CreationSettings(
            title: "GeometriaApp",
            size: .init(width: 1000, height: 750)
        )

        window = DirectXWindow(settings: settings)
        window?.show()

        /*
        let main = GeometriaWindow(size: .init(width: 1000, height: 750))
        app.show(content: main)

        self.main = main
        */
    }
}
