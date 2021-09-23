import GeometriaAppLib
import ImagineUI
import SwiftBlend2D
import WinSDK

class MainWindow: Window {
    var app: Blend2DApp!
    var blImage: BLImage!
    var redrawBounds: [UIRectangle] = []

    override func initialize() {
        super.initialize()

        globalTextClipboard = Win32TextClipboard()
        
        let fontUrl = Resources.bundle.path(forResource: "NotoSans-Regular", ofType: "ttf")!
        
        let stopwatch = Stopwatch.start()

        do {
            try UISettings.initialize(
                .init(fontManager: Blend2DFontManager(),
                      defaultFontPath: fontUrl,
                      timeInSecondsFunction: { stopwatch.timeIntervalSinceStart() })
            )
            
            let app = RaytracerApp(width: size.width, height: size.height)
            app.delegate = self
            self.app = app
            
            blImage = BLImage(width: app.width * Int(app.appRenderScale.x),
                              height: app.height * Int(app.appRenderScale.y),
                              format: .xrgb32)
        } catch {
            log.error("Error creating Raytracer demo: \(error)")
        }
    }

    override func onPaint() {
        guard let dc = GetDC(hwnd) else {
            return
        }
        

    }
}

extension MainWindow: Blend2DAppDelegate {
    func invalidate(bounds: UIRectangle) {
        // TODO: Implement invalidation
    }

    func setMouseCursor(_ cursor: MouseCursorKind) {
        // TODO: Implement cursor change
    }

    func setMouseHiddenUntilMouseMoves() {
        // TODO: Implement cursor hiding
    }
}
