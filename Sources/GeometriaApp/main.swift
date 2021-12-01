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

#elseif os(macOS)

import GeometriaMacOS

@main
func main() {
    startApp()
}

#else

#error("Unsupported target platform. Supported platforms: macOS, Windows")

#endif
