/// Wraps information about a raycast instance, such as bounce counts.
struct RayStats {
    /// The current number of bounces from the main raycast.
    var bounceCount: Int

    /// The maximum number of bounces permitted from the original raycast point.
    var maxBounces: Int

    func bounced() -> Self {
        .init(bounceCount: bounceCount + 1, maxBounces: maxBounces)
    }

    mutating func addBounce() {
        bounceCount += 1
    }
}
