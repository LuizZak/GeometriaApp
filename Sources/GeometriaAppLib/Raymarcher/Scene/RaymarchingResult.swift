struct RaymarchingResult {
    var distance: Double

    @_transparent
    static func merge(_ r0: Self, _ r1: Self, distance: Double) -> Self {
        .init(distance: distance)
    }

    @_transparent
    static func union(_ r0: Self, _ r1: Self) -> Self {
        let result = min(r0.distance, r1.distance)

        return merge(r0, r1, distance: result)
    }

    @_transparent
    static func subtraction(_ r0: Self, _ r1: Self) -> Self {
        let result = max(r0.distance, -r1.distance)

        return merge(r0, r1, distance: result)
    }

    @_transparent
    static func intersection(_ r0: Self, _ r1: Self) -> Self {
        let result = max(r0.distance, r1.distance)

        return merge(r0, r1, distance: result)
    }

    @_transparent
    static func emptyResult() -> Self {
        .init(distance: .infinity)
    }
}
