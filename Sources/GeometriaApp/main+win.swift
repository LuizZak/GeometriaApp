#if os(Windows)

import WinSDK
import GeometriaWindows

@_silgen_name("wWinMain")
func wWinMain(_ hInstance: HINSTANCE,
              _ hPrevInstance: HINSTANCE,
              _ pCmdLine: PWSTR,
              _ nCmdShow: CInt) -> CInt {

    return try! start()
}

#else

#error("Unsupported target platform. Supported platforms: macOS, Windows")

#endif
