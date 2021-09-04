import AppKit
import SwiftUI
import SwiftBlend2D

class CanvasView: NSView {
    var link: CVDisplayLink?
    
    var workQueueLength: ConcurrentValue<Int> = .init(wrappedValue: 0)
    
    var imageContext: CGContext?
    var image: CGImage?
    
    var usingCGImage = false
    
    var sample: Blend2DSample!
    var blImage: BLImage!
    var redrawBounds: [NSRect] = []
    
    override var bounds: NSRect {
        get {
            return super.bounds
        }
        set {
            super.bounds = newValue
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initializeDisplayLink()
        initializeSample()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeDisplayLink()
        initializeSample()
    }
    
    private func initializeDisplayLink() {
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let link = link else {
            return
        }
        
        CVDisplayLinkSetOutputCallback(
            link,
            displayLinkOutputCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        CVDisplayLinkStart(link)
    }
    
    private func initializeSample() {
        let url = Bundle.module.path(forResource: "NotoSans-Regular", ofType: "ttf")!
        Fonts.defaultFontFace = try! BLFontFace(fromFile: url)
        
        let sample = GeometriaSample(width: Int(bounds.width), height: Int(bounds.height))
        sample.delegate = self
        self.sample = sample
        
        blImage = BLImage(width: sample.width * Int(sample.sampleRenderScale.x),
                          height: sample.height * Int(sample.sampleRenderScale.y),
                          format: .xrgb32)
        
        recreateCgImageContext()
    }
    
    override func layout() {
        super.layout()
        
        resizeSample()
    }
    
    override func viewWillStartLiveResize() {
        super.viewWillStartLiveResize()
        
        sample.willStartLiveResize()
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        
        sample.didEndLiveResize()
    }
    
    private func resizeSample() {
        sample.resize(width: Int(bounds.width), height: Int(bounds.height))
        
        blImage = BLImage(width: sample.width * Int(sample.sampleRenderScale.x),
                          height: sample.height * Int(sample.sampleRenderScale.y),
                          format: .xrgb32)
        
        recreateCgImageContext()
        
        redrawBounds.append(bounds)
        
        update()
    }
    
    private func recreateCgImageContext() {
        let imageData = blImage.getImageData()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        if usingCGImage {
            imageContext = nil
            
            var bitmapInfo: CGBitmapInfo = [.byteOrder32Little]
            bitmapInfo.insert(CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))
            
            let length = imageData.stride * Int(imageData.size.h)
            guard let provider = CGDataProvider(dataInfo: nil, data: imageData.pixelData, size: length, releaseData: { _, _, _ in }) else {
                return
            }
            
            image = CGImage(width: Int(imageData.size.w),
                            height: Int(imageData.size.h),
                            bitsPerComponent: 8,
                            bitsPerPixel: 32,
                            bytesPerRow: imageData.stride,
                            space: colorSpace,
                            bitmapInfo: bitmapInfo,
                            provider: provider,
                            decode: nil,
                            shouldInterpolate: false,
                            intent: .defaultIntent)
        } else {
            image = nil
            
            var bitmapInfo: UInt32 = 0
            
            bitmapInfo |= CGImageAlphaInfo.noneSkipFirst.rawValue
            bitmapInfo |= CGImageByteOrderInfo.order32Little.rawValue
            
            imageContext = CGContext(data: imageData.pixelData,
                                     width: blImage.width,
                                     height: blImage.height,
                                     bitsPerComponent: 8,
                                     bytesPerRow: imageData.stride,
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let mouseEvent = makeMouseEventArgs(event)
        
        sample.mouseDown(event: mouseEvent)
        
        becomeFirstResponder()
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        let mouseEvent = makeMouseEventArgs(event)
        
        sample.mouseMoved(event: mouseEvent)
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        
        let mouseEvent = makeMouseEventArgs(event)
        
        sample.mouseMoved(event: mouseEvent)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        let mouseEvent = makeMouseEventArgs(event)
        
        sample.mouseUp(event: mouseEvent)
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        
        let mouseEvent = makeMouseEventArgs(event)
        
        sample.mouseScroll(event: mouseEvent)
    }
    
    override func keyDown(with event: NSEvent) {
        let keyboardEvent = makeKeyboardEventArgs(event)
        
        sample.keyDown(event: keyboardEvent)
    }
    
    override func keyUp(with event: NSEvent) {
        let keyboardEvent = makeKeyboardEventArgs(event)
        
        sample.keyUp(event: keyboardEvent)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        trackingAreas.forEach(removeTrackingArea(_:))
        
        let options: NSTrackingArea.Options = [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .mouseMoved]
        let area = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        
        addTrackingArea(area)
    }
    
    private func makeMouseEventArgs(_ event: NSEvent) -> MouseEventArgs {
        let windowPoint = event.locationInWindow
        let point = self.convert(windowPoint, from: nil)
        
        let mouseButton: MouseButton
        
        switch event.type {
        case .leftMouseDown, .leftMouseUp, .leftMouseDragged:
            mouseButton = .left
        case .rightMouseDown, .rightMouseUp, .rightMouseDragged:
            mouseButton = .right
        case .otherMouseDown, .otherMouseUp, .otherMouseDragged:
            mouseButton = .middle
        default:
            mouseButton = .none
        }
        
        var scrollingDeltaX = 0.0
        var scrollingDeltaY = 0.0
        if event.type == .scrollWheel {
            scrollingDeltaX = Double(event.scrollingDeltaX)
            scrollingDeltaY = Double(event.scrollingDeltaY)
        }
        
        let clickCount: Int
        if event.type == .leftMouseDown || event.type == .rightMouseDown || event.type == .otherMouseDown {
            clickCount = event.clickCount
        } else {
            clickCount = 0
        }
        
        return MouseEventArgs(location: Vector(x: Double(point.x), y: Double(bounds.height - point.y)),
                              buttons: mouseButton,
                              delta: Vector(x: scrollingDeltaX, y: scrollingDeltaY),
                              clicks: clickCount)
    }
    
    func incrementUpdateWorkQueue() {
        workQueueLength.modifyingValue { $0 += 1 }
    }
    
    func update() {
        sample.update(CACurrentMediaTime())
        
        if let first = redrawBounds.first {
            let options = BLContext.CreateOptions(threadCount: 4)
            
            let ctx = BLContext(image: blImage, options: options)!
            
            sample.render(context: ctx)
            
            ctx.flush(flags: .sync)
            ctx.end()
            
            let reduced = redrawBounds.reduce(first, { $0.union($1) })
            setNeedsDisplay(reduced)
            
            redrawBounds.removeAll()
        }
        
        workQueueLength.modifyingValue {
            $0 = max(0, $0 - 1)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current else {
            return
        }
        context.imageInterpolation = .none
        context.shouldAntialias = false
        context.compositingOperation = .copy
        
        if usingCGImage {
            recreateCgImageContext()
            
            if let image = image {
                context.cgContext.draw(image, in: bounds)
            }
        } else {
            if let cgImage = imageContext?.makeImage() {
                context.cgContext.draw(cgImage, in: bounds)
            }
        }
        
        context.flushGraphics()
    }
}

extension CanvasView: Blend2DSampleDelegate {
    func invalidate(bounds: Rectangle) {
        let rectBounds = NSRect(x: bounds.x,
                                y: Double(self.bounds.height) - bounds.y - bounds.height,
                                width: bounds.width,
                                height: bounds.height)
        
        let intersectedBounds = rectBounds.intersection(self.bounds)
        
        redrawBounds.append(intersectedBounds)
    }
}

func displayLinkOutputCallback(displayLink: CVDisplayLink,
                               _ inNow: UnsafePointer<CVTimeStamp>,
                               _ inOutputTime: UnsafePointer<CVTimeStamp>,
                               _ flagsIn: CVOptionFlags,
                               _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                               _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
    
    guard let context = displayLinkContext else {
        return kCVReturnSuccess
    }
    
    let view =
    Unmanaged<CanvasView>
        .fromOpaque(context)
        .takeUnretainedValue()
    
    if view.workQueueLength.wrappedValue > 0 {
        return kCVReturnSuccess
    }
    
    view.incrementUpdateWorkQueue()
    
    DispatchQueue.main.async {
        view.update()
    }
    
    return kCVReturnSuccess
}
