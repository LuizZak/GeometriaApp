/// Given two `SortedRayHits` sequences, lazily iterates between each hit of the
/// two hit sequences in order of `RayHit.distanceSquared`.
///
/// The yielded element is an enum with the `RayHit`, encased in `IteratorElement`,
/// indicating from which sequence the ray hit originated from.
///
/// In case the lists contain hits with the same `RayHit.distanceSquared` value,
/// this iterator is biased to serve the value from `s0` before `s1`.
public struct SortedRayHitsZipper: IteratorProtocol {
    @usableFromInline
    var s0: SortedRayHits

    @usableFromInline
    var s1: SortedRayHits

    @usableFromInline
    var s0Index: Int

    @usableFromInline
    var s1Index: Int

    @inlinable
    public init(s0: SortedRayHits, s1: SortedRayHits) {
        self.s0 = s0
        self.s1 = s1

        s0Index = 0
        s1Index = 0
    }

    @inlinable
    public mutating func next() -> Element? {
        switch (s0Index == s0.endIndex, s1Index == s1.endIndex) {
        case (true, true):
            return nil

        case (false, true):
            defer { s0Index += 1 }
            return .s0(s0[s0Index])

        case (true, false):
            defer { s1Index += 1 }
            return .s1(s1[s1Index])
        
        case (false, false):
            if s0[s0Index].distanceSquared <= s1[s1Index].distanceSquared {
                defer { s0Index += 1 }
                return .s0(s0[s0Index])
            }

            defer { s1Index += 1 }
            return .s1(s1[s1Index])
        }
    }

    /// Represents a yielded element from this zipper. Is either `.s0` or `.s1`,
    /// depending from which sequence the current element was yielded from.
    public enum Element {
        case s0(RayHit)
        case s1(RayHit)

        /// Returns the ray hit from this element.
        @inlinable
        public var rayHit: RayHit {
            switch self {
            case .s0(let hit), .s1(let hit):
                return hit
            }
        }
    }
}
