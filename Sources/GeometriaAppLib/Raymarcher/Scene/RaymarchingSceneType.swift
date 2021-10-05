import SwiftBlend2D

protocol RaymarchingSceneType: SceneType {
    var skyColor: BLRgba32 { get }
    var sunDirection: RVector3D { get }

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult
}
