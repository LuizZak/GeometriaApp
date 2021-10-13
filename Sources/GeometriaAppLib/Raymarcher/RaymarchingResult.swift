struct RaymarchingResult: Hashable {
    var distance: Double
    var material: MaterialId?

    @_transparent
    init(distance: Double, material: MaterialId?) {
        self.distance = distance
        self.material = material
    }

    @_transparent
    func addingDistance(_ distance: Double) -> Self {
        .init(distance: self.distance + distance, material: self.material)
    }

    @_transparent
    func withMaterial(_ material: MaterialId?) -> Self {
        .init(distance: self.distance, material: material)
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

    /// Returns whether `lhs` has a smaller `distance` property than `rhs`.
    @_transparent
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.distance < rhs.distance
    }

    /// Returns whether `lhs` has a greater `distance` property than `rhs`.
    @_transparent
    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.distance > rhs.distance
    }
}

extension RaymarchingResult {
    @_transparent
    static prefix func - (lhs: Self) -> Self {
        .init(distance: -lhs.distance, material: lhs.material)
    }
}

@_transparent
func abs(_ value: RaymarchingResult) -> RaymarchingResult {
    .init(distance: abs(value.distance), material: value.material)
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
func mixMaterial(_ lhs: MaterialId?, _ rhs: MaterialId?, factor: Double) -> Int? {
    // TODO: Do proper material mixing?
    lhs ?? rhs
}

@_transparent
func mix(_ lhs: RaymarchingResult, _ rhs: RaymarchingResult, factor: Double) -> RaymarchingResult {
    let dist = lhs.distance * (1 - factor) + rhs.distance * factor

    return .init(distance: dist, material: mixMaterial(lhs.material, rhs.material, factor: factor))
}
