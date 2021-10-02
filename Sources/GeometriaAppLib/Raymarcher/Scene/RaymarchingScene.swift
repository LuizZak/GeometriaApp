import SwiftBlend2D

struct RaymarchingScene<T: RaymarchingElement>: RaymarchingSceneType {
    var root: T
    var skyColor: BLRgba32
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        root.signedDistance(to: point, current: current)
    }
}

extension RaymarchingElementBuilder {
    static func makeScene<T>(skyColor: BLRgba32, @RaymarchingElementBuilder _ builder: () -> T) -> RaymarchingScene<T> where T: RaymarchingElement {
        .init(root: builder(), skyColor: .cornflowerBlue)
    }
}
