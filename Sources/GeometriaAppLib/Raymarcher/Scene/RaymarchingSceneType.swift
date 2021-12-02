import SwiftBlend2D

protocol RaymarchingSceneType: SceneType {
    var skyColor: BLRgba32 { get }
    var sunDirection: RVector3D { get }

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult

    /// Walks a visitor through this scene's elements.
    func walk<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType
}
