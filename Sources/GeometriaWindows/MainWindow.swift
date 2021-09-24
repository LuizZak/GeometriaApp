import GeometriaAppLib
import ImagineUI
import SwiftBlend2D
import WinSDK

class MainWindow: Window {
    var app: Blend2DApp!
    var blImage: BLImage?
    var redrawBounds: [UIRectangle] = []
    let stopwatch = Stopwatch.start()

    override func initialize() {
        super.initialize()

        globalTextClipboard = Win32TextClipboard()
        
        let fontUrl = Resources.bundle.path(forResource: "NotoSans-Regular", ofType: "ttf")!
        
        do {
            try UISettings.initialize(
                .init(fontManager: Blend2DFontManager(),
                      defaultFontPath: fontUrl,
                      timeInSecondsFunction: { [stopwatch] in stopwatch.timeIntervalSinceStart() })
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

    private func update() {
        app.update(stopwatch.timeIntervalSinceStart())
        
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
        setNeedsDisplay(.init(from: reduced))
        
        redrawBounds.removeAll()
    }

    private func resizeApp() {
        app.resize(width: Int(size.width), height: Int(size.height))
        
        blImage = BLImage(width: app.width * Int(app.appRenderScale.x),
                          height: app.height * Int(app.appRenderScale.y),
                          format: .xrgb32)
        
        redrawBounds.append(.init(location: .zero, size: size.asUISize))
        
        update()
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
        let length = imageData.stride * Int(imageData.size.h)
        
        // Creating temp bitmap
        let map = CreateBitmap(Int32(blImage.width), // width. 512 in my case
                               Int32(blImage.height), // height
                               1, // Color Planes, unfortanutelly don't know what is it actually. Let it be 1
                               8*4, // Size of memory for one pixel in bits (in win32 4 bytes = 4*8 bits)
                               imageData.pixelData) // pointer to array

        // Temp HDC to copy picture
        let src = CreateCompatibleDC(hdc) // hdc - Device context for window, I've got earlier with GetDC(hWnd) or GetDC(NULL);
        // print(imageData[x: 50, y: 50])
        SelectObject(src, map) // Inserting picture into our temp HDC

        // Copy image from temp HDC to window
        BitBlt(hdc, // Destination
               0,  // x and
               0,  // y - upper-left corner of place, where we'd like to copy
               Int32(blImage.width), // width of the region
               Int32(blImage.height), // height
               src, // source
               0,   // x and
               0,   // y of upper left corner  of part of the source, from where we'd like to copy
               SRCCOPY) // Defined DWORD to juct copy pixels. Watch more on msdn;
        
        DeleteObject(map)

        DeleteDC(src) // Deleting temp HDC
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
