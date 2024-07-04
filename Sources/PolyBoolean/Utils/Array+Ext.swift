extension Array where Element: Equatable {
    /// Removes duplicates within this array, while maintaining the relative order
    /// of the items.
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }

    /// Removes duplicates within this array, while maintaining the relative order
    /// of the items.
    func removingDuplicates() -> Self {
        var seen: Self = []
        var result: Self = []

        for item in self {
            guard !seen.contains(item) else {
                continue
            }

            seen.append(item)
            result.append(item)
        }

        return result
    }
}

extension Array where Element: Hashable {
    /// Removes duplicates within this array, while maintaining the relative order
    /// of the items.
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }

    /// Removes duplicates within this array, while maintaining the relative order
    /// of the items.
    func removingDuplicates() -> Self {
        var seen: Set<Element> = []
        var result: Self = []

        for item in self {
            guard seen.insert(item).inserted else {
                continue
            }

            result.append(item)
        }

        return result
    }
}
