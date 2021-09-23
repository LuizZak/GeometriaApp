#if os(Windows)

import GeometriaWindows

GeometriaAppDelegate.main()

#elseif os(macOS)

import GeometriaMacOS
startApp()

#else

#error("Unsupported target platform. Supported platforms: macOS, Windows")

#endif
