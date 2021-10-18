import struct WinSDK.UINT
import SwiftCOM

extension IDXGIFactory {
    func Adapters() throws -> [IDXGIAdapter] {
        var adapters: [IDXGIAdapter] = []

        var index: UINT = 0
        repeat {
            defer { index += 1 }
            do {
                adapters.append(try EnumAdapters(index).QueryInterface())
            } catch let error as COMError where error.hr == DXGI_ERROR_NOT_FOUND {
                break
            }
        } while true

        return adapters
    }
}
