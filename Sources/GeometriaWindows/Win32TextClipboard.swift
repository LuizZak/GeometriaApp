import WinSDK
import ImagineUI

class Win32TextClipboard: TextClipboard {
    func getText() -> String? {
        guard OpenClipboard(nil) else {
            return nil
        }
        defer { CloseClipboard() }

        guard let hClipboardData = GetClipboardData(UINT(CF_UNICODETEXT)) else {
            return nil
        }
        guard let pchData = GlobalLock(hClipboardData) else {
            return nil
        }
        defer { GlobalUnfix(hClipboardData) }

        return String(from: pchData.assumingMemoryBound(to: WCHAR.self))
    }
    
    func setText(_ text: String) {
        guard OpenClipboard(nil) else {
            return
        }
        defer { CloseClipboard() }

        EmptyClipboard()

        let cString = text.wide
        let size = SIZE_T(cString.count)

        guard let data = GlobalAlloc(0, size) else {
            return
        }
        guard let pchData = GlobalLock(data) else {
            return
        }
        defer { GlobalUnlock(data) }

        cString.withUnsafeBufferPointer { pointer in
            guard let baseAddress = pointer.baseAddress else {
                return
            }

            memcpy(pchData, baseAddress, Int(size))
        }
    }
    
    func containsText() -> Bool {
        return getText() != nil
    }
}
