extension Range {
    /// Returns the subtraction of `self` against `other`, such that the resulting
    /// interval is the range of elements in `self` that do not coincide with
    /// `other`.
    ///
    /// If the result is an empty range, `nil` is returned, instead.
    public func subtracting(_ other: Self) -> Self? {
        if !overlaps(other) {
            return self
        }

        if self.lowerBound < other.lowerBound {
            let low = self.lowerBound
            let high = other.lowerBound

            if low >= high {
                return nil
            }

            return (low..<high)
        } else {
            let low = other.upperBound
            let high = self.lowerBound

            if low >= high {
                return nil
            }

            return (low..<high)
        }
    }

    /// Returns the intersection of `self` against `other`, such that the resulting
    /// interval is the range of elements in `self` that overlap with `other`.
    ///
    /// If the result is an empty range, `nil` is returned, instead.
    public func intersection(_ other: Self) -> Self? {
        if !overlaps(other) {
            return nil
        }

        let low = Swift.max(lowerBound, other.lowerBound)
        let high = Swift.min(upperBound, other.upperBound)

        return (low..<high)
    }

    /// Returns the union of this interval with another, such that the resulting
    /// interval is the minimal interval length capable of containing both intervals.
    public func union(_ other: Self) -> Self {
        let low = Swift.min(lowerBound, other.lowerBound)
        let high = Swift.max(upperBound, other.upperBound)

        return (low..<high)
    }
}

extension ClosedRange {
    /// Returns the subtraction of `self` against `other`, such that the resulting
    /// interval is the range of elements in `self` that do not coincide with
    /// `other`.
    ///
    /// If the result is an empty range, `nil` is returned, instead.
    public func subtracting(_ other: Self) -> Self? {
        if !overlaps(other) {
            return self
        }

        if self.lowerBound < other.lowerBound {
            let low = self.lowerBound
            let high = other.lowerBound

            if low > high {
                return nil
            }

            return (low...high)
        } else {
            let low = other.upperBound
            let high = self.lowerBound

            if low > high {
                return nil
            }

            return (low...high)
        }
    }

    /// Returns the intersection of `self` against `other`, such that the resulting
    /// interval is the range of elements in `self` that overlap with `other`.
    ///
    /// If the result is an empty range, `nil` is returned, instead.
    public func intersection(_ other: Self) -> Self? {
        if !overlaps(other) {
            return nil
        }

        let low = Swift.max(lowerBound, other.lowerBound)
        let high = Swift.min(upperBound, other.upperBound)

        return (low...high)
    }

    /// Returns the union of this interval with another, such that the resulting
    /// interval is the minimal interval length capable of containing both intervals.
    public func union(_ other: Self) -> Self {
        let low = Swift.min(lowerBound, other.lowerBound)
        let high = Swift.max(upperBound, other.upperBound)

        return (low...high)
    }
}

extension Sequence {
    /// Returns the result of subtracting the given range from all ranges within
    /// `self`, such that no element within `range` is contained in the remaining
    /// elements of the resulting array.
    public func subtracting<Bound>(_ range: Element) -> [Element] where Element == Range<Bound> {
        var result: [Element] = []

        for next in self {
            if let interval = next.subtracting(range) {
                result.append(interval)
            }
        }

        return result
    }

    /// Returns the result of subtracting the given range from all ranges within
    /// `self`, such that no element within `range` is contained in the remaining
    /// elements of the resulting array.
    public func subtracting<Bound>(_ range: Element) -> [Element] where Element == ClosedRange<Bound> {
        var result: [Element] = []

        for next in self {
            if let interval = next.subtracting(range) {
                result.append(interval)
            }
        }

        return result
    }

    /// Returns a new array of intervals such that it covers the same interval
    /// ranges with the minimal number of intervals possible.
    ///
    /// Effectively simplifies long interwind interval lists with many overlapping
    /// intervals into single, longer segments that cover the same interval ranges.
    public func compactedIntervals<Bound>() -> [Element] where Element == Range<Bound> {
        // Sort intervals first
        let arranged = sorted { $0.lowerBound < $1.lowerBound }

        var result: [Element] = []
        var current: Element?

        // Pick intervals, creating unions over overlapping interval regions,
        // and pushing these intervals to a result array once no more overlapping
        // intervals are found, repeating until all intervals are exhausted

        for inter in arranged {
            guard let cur = current else {
                current = inter
                continue
            }

            if cur.overlaps(inter) {
                current = cur.union(inter)
            } else {
                // Append and reset
                current = inter
                result.append(cur)
            }
        }

        if let current = current {
            result.append(current)
        }

        return result
    }

    /// Returns a new array of intervals such that it covers the same interval
    /// ranges with the minimal number of intervals possible.
    ///
    /// Effectively simplifies long interwind interval lists with many overlapping
    /// intervals into single, longer segments that cover the same interval ranges.
    public func compactedIntervals<Bound>() -> [Element] where Element == ClosedRange<Bound> {
        // Sort intervals first
        let arranged = sorted { $0.lowerBound < $1.lowerBound }

        var result: [Element] = []
        var current: Element?

        // Pick intervals, creating unions over overlapping interval regions,
        // and pushing these intervals to a result array once no more overlapping
        // intervals are found, repeating until all intervals are exhausted

        for inter in arranged {
            guard let cur = current else {
                current = inter
                continue
            }

            if cur.overlaps(inter) {
                current = cur.union(inter)
            } else {
                // Append and reset
                current = inter
                result.append(cur)
            }
        }

        if let current = current {
            result.append(current)
        }

        return result
    }
}

extension Array {
    /// Subtracts the given range from all ranges within `self`, such that no
    /// element within `range` is contained in the remaining elements.
    public mutating func subtract<Bound>(_ range: Element) where Element == Range<Bound> {
        self = self.subtracting(range)
    }

    /// Subtracts the given range from all ranges within `self`, such that no
    /// element within `range` is contained in the remaining elements.
    public mutating func subtract<Bound>(_ range: Element) where Element == ClosedRange<Bound> {
        self = self.subtracting(range)
    }

    /// Compacts intervals within this collection such that it covers the same
    /// interval ranges with the minimal number of intervals possible.
    ///
    /// Effectively simplifies long interwind interval lists with many overlapping
    /// intervals into single, longer segments that cover the same interval ranges.
    public mutating func compactIntervals<Bound>() where Element == Range<Bound> {
        self = self.compactedIntervals()
    }

    /// Compacts intervals within this collection such that it covers the same
    /// interval ranges with the minimal number of intervals possible.
    ///
    /// Effectively simplifies long interwind interval lists with many overlapping
    /// intervals into single, longer segments that cover the same interval ranges.
    public mutating func compactIntervals<Bound>() where Element == ClosedRange<Bound> {
        self = self.compactedIntervals()
    }
}
