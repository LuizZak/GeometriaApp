import SwiftBlend2D

protocol RaymarchingSceneType {
    var skyColor: BLRgba32 { get }

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult
}
