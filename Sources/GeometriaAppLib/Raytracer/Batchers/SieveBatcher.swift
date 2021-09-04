import Foundation
import Geometria

/// Batcher that feeds pixel coordinates based on multiples of prime numbers,
/// feeding the largest prime multiples first, then reducing until
class SieveBatcher: RaytracerBatcher {
    typealias PixelCoordinates = Vector2i
    
    /// Pre-computed list of prime numbers which will be incremented later while
    /// computing prime counters
    private var primes: [Int] = [
        2, 3, 7, 11, 13, 17, 23, 29, 31, 37, 41, 43, 47, 53, 55, 59, 61, 65, 67,
        71, 73, 79, 83, 85, 89, 95, 97, 101, 103, 107, 109, 113, 115, 125, 127,
        131, 137, 139, 145, 149, 151, 155, 157, 163, 167, 173, 179, 181, 185,
        191, 193, 197, 199, 205, 211, 215, 223, 227, 229, 233, 235, 239, 241,
        251, 257, 263, 265, 269, 271, 277, 281, 283, 293, 295, 305, 307, 311,
        313, 317, 331, 335, 337, 347, 349, 353, 355, 359, 361, 365, 367, 373,
        379, 383, 389, 395, 397, 401, 409, 415, 419, 421, 431, 433, 437, 439,
        443, 445, 449, 457, 461, 463, 467, 475, 479, 485, 487, 491, 499, 503,
        505, 509, 515, 521, 523, 535, 541, 545, 547, 551, 557, 563, 565, 569,
        571, 577, 587, 589, 593, 599, 601, 607, 613, 617, 619, 625, 631, 635,
        641, 643, 647, 653, 655, 659, 661, 673, 677, 683, 685, 691, 695, 701,
        703, 709, 719, 725, 727, 733, 739, 743, 745, 751, 755, 757, 761, 769,
        773, 775, 779, 785, 787, 797, 809, 811, 815, 817, 821, 823, 827, 829,
        835, 839, 853, 857, 859, 863, 865, 877, 881, 883, 887, 893, 895, 905,
        907, 911, 919, 925, 929, 937, 941, 947, 953, 955, 965, 967, 971, 977,
        983, 985, 991, 995, 997, 1007, 1009, 1013, 1019, 1021, 1025, 1031
    ]
    
    private var multiplesCounters: [MultipleIndexCounter] = []
    private var multiplesCountersIndex: Int = 0
    
    private var servedPixels: Set<PixelCoordinates> = []
    private var pixelCount: Int = 0
    private var viewportSize: PixelCoordinates = .zero
    
    var hasBatches: Bool = false
    
    init() {
        multiplesCounters = primes.map(createMultiplesCounter).reversed()
    }
    
    func initialize(viewportSize: PixelCoordinates) {
        self.viewportSize = viewportSize
        pixelCount = viewportSize.x * viewportSize.y
        servedPixels.removeAll()
        fillMultiplesCounters()
        
        hasBatches = true
    }
    
    func nextBatch(maxSize: Int) -> [PixelCoordinates]? {
        guard hasBatches else {
            return nil
        }
        if multiplesCountersIndex >= multiplesCounters.count {
            hasBatches = false
            return nil
        }
        
        var pixels: [PixelCoordinates] = []
        pixels.reserveCapacity(maxSize)
        
        while pixels.count < maxSize {
            guard let pixel = nextPixel() else {
                hasBatches = false
                break
            }
            if !servedPixels.insert(pixel).inserted {
                continue
            }
            
            pixels.append(pixel)
        }
        
        return pixels
    }
    
    private func nextPixel() -> PixelCoordinates? {
        // Attempt all prime counters for a prime multiple until we exhausted
        // them all
        while multiplesCountersIndex < multiplesCounters.count {
            guard let p = multiplesCounters[multiplesCountersIndex].next(upTo: pixelCount) else {
                multiplesCountersIndex += 1
                continue
            }
            
            let x = p % viewportSize.x
            let y = p / viewportSize.x
            
            return .init(x: x, y: y)
        }
        
        return nil
    }
    
    private func fillMultiplesCounters() {
        // Reset prime counters
        for i in 0..<multiplesCounters.count {
            multiplesCounters[i].currentMultiple = 1
        }
        
        let pixelCountsToCheck = Int(sqrt(Double(pixelCount)))
        var i = 39
        while i < pixelCountsToCheck {
            defer {
                i += 2 // Skip even numbers
            }
            
            if sieveIsPrime(i) {
                multiplesCounters.insert(createMultiplesCounter(base: i), at: 0)
            }
        }
        
        // Insert 1-counter at end of the list to fill remaining of screen
        multiplesCounters.append(createMultiplesCounter(base: 1))
    }
    
    private func sieveIsPrime(_ number: Int) -> Bool {
        let root2 = Int(sqrt(Double(number)))
        
        for p in primes {
            if p > root2 {
                primes.append(number)
                return true
            }
            
            if number.isMultiple(of: p) {
                return false
            }
        }
        
        return true
    }
    
    private func createMultiplesCounter(base: Int) -> MultipleIndexCounter {
        MultipleIndexCounter(base: base, currentMultiple: 1)
    }
    
    struct MultipleIndexCounter {
        var base: Int
        var currentMultiple: Int
        
        mutating func next(upTo: Int) -> Int? {
            if base * currentMultiple >= upTo {
                return nil
            }
            
            defer { currentMultiple += 1 }
            return base * currentMultiple
        }
    }
}
