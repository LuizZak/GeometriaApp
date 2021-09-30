#if os(Windows)

import GeometriaWindows

_=try start()

#elseif os(macOS)

import GeometriaMacOS
startApp()

#else

#error("Unsupported target platform. Supported platforms: macOS, Windows")

#endif
