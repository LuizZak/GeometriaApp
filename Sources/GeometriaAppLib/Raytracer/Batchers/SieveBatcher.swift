import Foundation

/// Batcher that feeds pixel coordinates based on multiples of prime numbers,
/// then later a sweep through the remaining pixels linearly.
class SieveBatcher: RaytracerBatcher {
    typealias PixelCoordinates = Vector2i
    
    /// Pre-computed list of prime numbers which will be incremented later while
    /// computing prime counters
    fileprivate var primes: [Int] = [
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
    
    private var indexCounters: [IndexCounter] = []
    private var nextCounterIndex: Int = 0
    
    /// Boolean map of all pixels that have been served
    private var servedPixelsMap: [Bool] = []
    private var viewportSize: PixelCoordinates = .zero
    
    fileprivate var pixelCount: Int = 0
    fileprivate var isRunning: Bool = true
    
    let displayName: String = "Prime Sieve"
    
    var batchesServedProgress: Double {
        Double(nextCounterIndex) / Double(indexCounters.count)
    }
    
    var hasBatches: Bool = false
    
    init() {
        
    }
    
    func initialize(viewportSize: PixelCoordinates) {
        self.viewportSize = viewportSize
        pixelCount = viewportSize.x * viewportSize.y
        servedPixelsMap = .init(repeating: false, count: pixelCount)
        fillMultiplesCounters()
        
        hasBatches = true
    }
    
    func nextBatch() -> RaytracingBatch? {
        while nextCounterIndex < indexCounters.count {
            defer { nextCounterIndex += 1 }
            
            return self.indexCounters[nextCounterIndex]
        }
        
        return nil
    }
    
    private func fillMultiplesCounters() {
        indexCounters.removeAll()
        
        // Insert 1-counter at start of the list to fill remaining pixels of
        // the screen while the other counters operate.
        indexCounters.append(createLinearCounter())
        
        // Pre-fill with prime pair counters
        indexCounters.append(contentsOf: primes.map { createPrimePairCounter(prime: $0) })
        
        // List of prime multiples counters to add to the end of the list after
        // all prime-pair multipliers.
        var primeMultiplesCounters = primes.map {
            createPrimeMultipleCounter(prime: $0)
        }
        
        let pixelCountsToCheck = Int(sqrt(Double(pixelCount)))
        var number = 39
        while number < pixelCountsToCheck {
            defer {
                number += 2 // Skip even numbers
            }
            
            if sieveIsPrime(number) {
                let primePair =
                createPrimePairCounter(
                    prime: number,
                    startAt: primes.count
                )
                
                indexCounters.append(primePair)
                
                // Store also a prime multiplier counter for later insertion
                let primeMultiple = createPrimeMultipleCounter(prime: number)
                primeMultiplesCounters.append(primeMultiple)
            }
        }
        
        // Now back-insert all stored prime multiple counters
        indexCounters.append(contentsOf: primeMultiplesCounters)
    }
    
    /// Attempts to insert a given number as a prime in the sieve.
    /// Returns the index of the prime in ``primes`` array, or `nil`, in case
    /// the value is not a prime number.
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
    
    private func createPrimePairCounter(prime: Int, startAt: Int = 0) -> PrimePairMultiplierCounter {
        PrimePairMultiplierCounter(prime: prime, nextPrimeIndex: startAt, viewportSize: viewportSize, context: self)
    }
    
    private func createPrimeMultipleCounter(prime: Int) -> PrimeMultipleCounter {
        PrimeMultipleCounter(prime: prime, viewportSize: viewportSize, context: self)
    }
    
    private func createLinearCounter() -> IndexCounter {
        LinearCounter(viewportSize: viewportSize, context: self)
    }
    
    class BaseCounter: IndexCounter {
        fileprivate weak var context: IndexCounterContext?
        var viewportSize: PixelCoordinates
        var isAtEnd: Bool = false
        
        fileprivate init(viewportSize: PixelCoordinates, context: IndexCounterContext?) {
            self.viewportSize = viewportSize
            self.context = context
        }
        
        fileprivate func nextPixelIndex(upTo maxIndex: Int) -> Int? {
            fatalError("Must be overriden by subclasses")
        }
        
        internal func nextPixel() -> Vector2i? {
            guard !isAtEnd else { return nil }
            guard let context = context else { return nil }
            
            guard let p = nextPixelIndex(upTo: context.pixelCount) else {
                return nil
            }
            
            assert(p < context.pixelCount)
            
            let x = p % viewportSize.x
            let y = p / viewportSize.x
            
            return PixelCoordinates(x: x, y: y)
        }
    }
    
    class LinearCounter: BaseCounter {
        var index = 0
        
        fileprivate override func nextPixelIndex(upTo maxIndex: Int) -> Int? {
            if index >= maxIndex {
                isAtEnd = true
                return nil
            }
            
            defer { index += 1 }
            return index
        }
    }
    
    class PrimeMultipleCounter: BaseCounter {
        var prime: Int
        var multiple: Int
        
        fileprivate init(prime: Int, viewportSize: PixelCoordinates, context: IndexCounterContext?, multiple: Int = 1) {
            self.prime = prime
            self.multiple = multiple
            
            super.init(viewportSize: viewportSize, context: context)
        }
        
        fileprivate override func nextPixelIndex(upTo maxIndex: Int) -> Int? {
            if prime * multiple >= maxIndex {
                isAtEnd = true
                return nil
            }
            
            defer { multiple += 1 }
            return prime * multiple
        }
    }
    
    class PrimePairMultiplierCounter: BaseCounter {
        var prime: Int
        var nextPrimeIndex: Int
        
        fileprivate init(prime: Int, nextPrimeIndex: Int, viewportSize: PixelCoordinates, context: IndexCounterContext?) {
            self.prime = prime
            self.nextPrimeIndex = nextPrimeIndex
            
            super.init(viewportSize: viewportSize, context: context)
        }
        
        fileprivate override func nextPixelIndex(upTo maxIndex: Int) -> Int? {
            guard let context = context else { return nil }
            
            if nextPrimeIndex >= context.primes.count {
                isAtEnd = true
                return nil
            }
            
            let p = context.primes[nextPrimeIndex]
            if prime * p >= maxIndex {
                return nil
            }
            
            defer { nextPrimeIndex += 1 }
            return prime * p
        }
    }
}

extension SieveBatcher: IndexCounterContext {
    
}

private protocol IndexCounterContext: AnyObject {
    var pixelCount: Int { get }
    var primes: [Int] { get }
    var isRunning: Bool { get }
}

private protocol IndexCounter: AnyObject, RaytracingBatch {
    var isAtEnd: Bool { get }
    
    func nextPixelIndex(upTo maxIndex: Int) -> Int?
}
