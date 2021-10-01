struct RaymarchingResult {
    var distance: Double

    static func emptyResult() -> Self {
        .init(distance: .infinity)
    }
}
