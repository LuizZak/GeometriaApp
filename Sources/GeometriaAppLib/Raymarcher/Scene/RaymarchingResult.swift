struct RaymarchingResult {
    var distance: Double

    @_transparent
    func addingDistance(_ distance: Double) -> Self {
        .init(distance: self.distance + distance)
    }

    @_transparent
    static func emptyResult() -> Self {
        .init(distance: .infinity)
    }

    @_transparent
    static func min(_ r0: Self, _ r1: Self) -> Self {
        if r0.distance < r1.distance {
            return r0
        }
        return r1
    }

    @_transparent
    static func max(_ r0: Self, _ r1: Self) -> Self {
        if r0.distance > r1.distance {
            return r0
        }
        return r1
    }

    @_transparent
    static func mix(_ r0: Self, _ r1: Self, factor: Double) -> Self {
        let dist = r0.distance * (1 - factor) + r1.distance * factor

        return .init(distance: dist)
    }
}

extension RaymarchingResult {
    @_transparent
    static prefix func - (lhs: Self) -> Self {
        .init(distance: -lhs.distance)
    }
}

@_transparent
func min(_ lhs: RaymarchingResult, _ rhs: RaymarchingResult) -> RaymarchingResult {
    RaymarchingResult.min(lhs, rhs)
}

@_transparent
func max(_ lhs: RaymarchingResult, _ rhs: RaymarchingResult) -> RaymarchingResult {
    RaymarchingResult.max(lhs, rhs)
}

@_transparent
func mix(_ lhs: RaymarchingResult, _ rhs: RaymarchingResult, factor: Double) -> RaymarchingResult {
    RaymarchingResult.mix(lhs, rhs, factor: factor)
}
