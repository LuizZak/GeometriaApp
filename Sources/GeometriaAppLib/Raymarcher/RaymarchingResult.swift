struct RaymarchingResult {
    var distance: Double
    var material: Material?

    init(distance: Double, material: Material?) {
        self.distance = distance
        self.material = material
    }

    @_transparent
    func addingDistance(_ distance: Double) -> Self {
        .init(distance: self.distance + distance, material: material)
    }

    @_transparent
    static func emptyResult() -> Self {
        .init(distance: .infinity, material: nil)
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
}

extension RaymarchingResult {
    @_transparent
    static prefix func - (lhs: Self) -> Self {
        .init(distance: -lhs.distance, material: lhs.material)
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
    let dist = lhs.distance * (1 - factor) + rhs.distance * factor

    return .init(distance: dist, material: mix(lhs.material, rhs.material, factor: factor))
}
