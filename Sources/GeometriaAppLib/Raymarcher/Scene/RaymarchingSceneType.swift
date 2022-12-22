import SwiftBlend2D

public protocol RaymarchingSceneType: SceneType {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult

    /// Walks a visitor through this scene's elements.
    func walk<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType
}
