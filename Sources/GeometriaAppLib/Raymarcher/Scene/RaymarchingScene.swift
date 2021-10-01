import SwiftBlend2D

struct RaymarchingScene<T: RaymarchingElement>: RaymarchingSceneType {
    var root: T
    var skyColor: BLRgba32

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        root.signedDistance(to: point, current: current)
    }
}

extension RaymarchingElementBuilder {
    static func makeScene<T>(skyColor: BLRgba32, @RaymarchingElementBuilder _ builder: () -> T) -> RaymarchingScene<T> where T: RaymarchingElement {
        .init(root: builder(), skyColor: .cornflowerBlue)
    }
}
