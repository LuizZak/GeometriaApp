import ImagineUI_Win
import MinWin32

class DirectXWindow: Win32Window {
    let dxManager: DirectXManager

    override init(size: Size) {
        dxManager = DirectXManager()

        super.init(size: size)
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
}
