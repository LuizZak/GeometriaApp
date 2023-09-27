// Derived from: https://github.com/apple/swift-algorithms/blob/fc8fdfd4dcc6d05f9d603c581fcbba643cb676df/Sources/Algorithms/Partition.swift#L170-L206
public extension Collection {
    /// Returns the start index of the partition of a collection that matches
    /// the given predicate.
    ///
    /// The collection must already be partitioned according to the predicate.
    /// That is, there should be an index `i` where for every element in
    /// `collection[..<i]` the predicate is `false`, and for every element in
    /// `collection[i...]` the predicate is `true`.
    ///
    /// - Parameter belongsInSecondPartition: A predicate that partitions the
    ///   collection.
    /// - Returns: The index of the first element in the collection for which
    ///   `predicate` returns `true`, or `endIndex` if there are no elements
    ///   for which `predicate` returns `true`.
    ///
    /// - Complexity: O(log *n*), where *n* is the length of this collection if
    ///   the collection conforms to `RandomAccessCollection`, otherwise O(*n*).
    @inlinable
    func partitioningIndex(
        where belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index {
        var n = count
        var l = startIndex
        
        while n > 0 {
            let half = n / 2
            let mid = index(l, offsetBy: half)

            if try belongsInSecondPartition(self[mid]) {
                n = half
            } else {
                l = index(after: mid)
                n -= half + 1
            }
        }

        return l
    } 
}
