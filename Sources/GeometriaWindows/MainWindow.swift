import GeometriaAppLib
import ImagineUI
import SwiftBlend2D
import WinSDK

class MainWindow: Window {
    private let refreshRate: Double = 60

    var app: Blend2DApp!
    var blImage: BLImage?
    var redrawBounds: [UIRectangle] = []
    let globalStopwatch = Stopwatch.start()
    var updateStopwatch = Stopwatch.start()

    override func initialize() {
        super.initialize()

        globalTextClipboard = Win32TextClipboard()
        
        let fontUrl = Resources.bundle.path(forResource: "NotoSans-Regular", ofType: "ttf")!
        
        do {
            try UISettings.initialize(
                .init(fontManager: Blend2DFontManager(),
                      defaultFontPath: fontUrl,
                      timeInSecondsFunction: { [globalStopwatch] in globalStopwatch.timeIntervalSinceStart() })
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

    override func updateAndPaint() {
        update()
        
        super.updateAndPaint()
    }

    func update() {
        guard updateStopwatch.timeIntervalSinceStart() > (1 / refreshRate) else {
            return
        }
        updateStopwatch.restart()

        app.update(globalStopwatch.timeIntervalSinceStart())
        
        guard let first = redrawBounds.first else {
            return
        }
        guard let blImage = blImage else {
            return
        }

        let options = BLContext.CreateOptions(threadCount: 4)
        
        let ctx = BLContext(image: blImage, options: options)!
        
        app.render(context: ctx)
        
        ctx.flush(flags: .sync)
        ctx.end()

        let reduced = redrawBounds.reduce(first, { $0.union($1) })
        redrawBounds.removeAll()

        setNeedsDisplay(.init(from: reduced))
    }

    private func resizeApp() {
        app.resize(width: Int(size.width), height: Int(size.height))
        
        blImage = BLImage(width: app.width * Int(app.appRenderScale.x),
                          height: app.height * Int(app.appRenderScale.y),
                          format: .xrgb32)
        
        redrawBounds.append(.init(location: .zero, size: size.asUISize))
    }

    override func onResize() {
        resizeApp()
    } 

    override func onPaint() {
        guard needsDisplay else {
            return
        }
        defer { needsDisplay = false }

        guard let hdc = GetDC(hwnd) else {
            return
        }
        guard let blImage = blImage else {
            return
        }
        
        let imageData = blImage.getImageData()
        
        let bitDepth: UINT = 32
        let map = 
        CreateBitmap(
            Int32(blImage.width),
            Int32(blImage.height),
            1, 
            bitDepth, 
            imageData.pixelData
        )
        defer { DeleteObject(map) }

        let src = CreateCompatibleDC(hdc)
        defer { DeleteDC(src) }

        SelectObject(src, map)
        BitBlt(hdc, 0, 0, Int32(blImage.width), Int32(blImage.height), src, 0, 0, SRCCOPY)
    }
}

extension MainWindow: Blend2DAppDelegate {
    func invalidate(bounds: UIRectangle) {
        redrawBounds.append(bounds)
    }

    func setMouseCursor(_ cursor: MouseCursorKind) {
        // TODO: Implement cursor change
    }

    func setMouseHiddenUntilMouseMoves() {
        // TODO: Implement cursor hiding
    }
}

private extension BLImageData {
    subscript(x x: Int, y y: Int) -> BLRgba32 {
        get {
            let offset = (x * MemoryLayout<BLRgba32>.stride + y * stride)
            
            return pixelData.load(fromByteOffset: offset, as: BLRgba32.self)
        }
        nonmutating set {
            let offset = (x * MemoryLayout<BLRgba32>.stride + y * stride)
            
            pixelData.storeBytes(of: newValue, toByteOffset: offset, as: BLRgba32.self)
        }
    }
}
