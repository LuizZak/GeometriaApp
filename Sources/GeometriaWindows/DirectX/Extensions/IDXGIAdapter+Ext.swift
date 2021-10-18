import struct WinSDK.UINT
import SwiftCOM

extension IDXGIAdapter {
    func Outputs() throws -> [IDXGIOutput] {
        var outputs: [IDXGIOutput] = []

        var index: UINT = 0
        repeat {
            defer { index += 1 }
            do {
                outputs.append(try EnumOutputs(index).QueryInterface())
            } catch let error as COMError where error.hr == DXGI_ERROR_NOT_FOUND {
                break
            }
        } while true

        return outputs
    }
}
