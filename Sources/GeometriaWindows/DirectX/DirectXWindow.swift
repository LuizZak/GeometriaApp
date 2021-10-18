import ImagineUI_Win
import MinWin32

class DirectXWindow: Win32Window {
    let dxManager: DirectXManager

    override init(settings: CreationSettings) {
        dxManager = DirectXManager()

        super.init(settings: settings)
    }

    override func initialize() {
        super.initialize()

        try! dxManager.initialize(window: self)
    }

    override func onClose(_ message: WindowMessage) {
        super.onClose(message)
        
        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }

    override func onPaint(_ message: WindowMessage) {
        do {
            try dxManager.render()
        } catch {
            WinLogger.error("Error while rendering: \(error)")
        }
    }
}
