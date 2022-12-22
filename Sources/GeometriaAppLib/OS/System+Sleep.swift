#if os(Windows)

import WinSDK

extension System {
    public static func sleep(milliseconds: Int64) {
        Sleep(DWORD(milliseconds))
    }
}

#elseif os(macOS) || os(Linux)

#if os(macOS)
import Darwin
#else
import Glibc
#endif

extension System {
    public static func sleep(milliseconds: Int64) {
        usleep(UInt32(milliseconds) * 1000)
    }
}

#else

extension System {
    public static func sleep(milliseconds: Int64) {
        fatalError("Unsupported system call")
    }
}

#endif
