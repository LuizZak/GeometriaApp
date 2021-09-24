import Foundation
import WinSDK

class Stopwatch {
    private static let frequency: LARGE_INTEGER = { 
        var ret: LARGE_INTEGER
        ret = LARGE_INTEGER()

        QueryPerformanceFrequency(&ret)
        
        return ret
    }()

    var start: LARGE_INTEGER = LARGE_INTEGER()
    
    private init() {
        QueryPerformanceCounter(&start)
    }
    
    /// Returns a number of seconds since this stopwatch was started.
    func timeIntervalSinceStart() -> TimeInterval {
        var end: LARGE_INTEGER = LARGE_INTEGER()
        QueryPerformanceCounter(&end)

        let delta_us = Double(end.QuadPart - start.QuadPart) / Double(Self.frequency.QuadPart)
        
        return delta_us
    }

    func restart() {
        QueryPerformanceCounter(&start)
    }
    
    static func start() -> Stopwatch {
        Stopwatch()
    }
}