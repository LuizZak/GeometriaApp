import SwiftBlend2D

typealias RaymarchingScene<T: RaymarchingElement> = Scene<T>

extension RaymarchingScene: RaymarchingSceneType {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        root.signedDistance(to: point, current: current)
    }

    /// Walks a visitor through this scene's elements.
    func walk<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        root.accept(visitor)
    }
}

extension RaymarchingElementBuilder {
    static func makeScene<T>(skyColor: BLRgba32, materials: MaterialMap, @RaymarchingElementBuilder _ builder: () -> T) -> RaymarchingScene<T> where T: RaymarchingElement {
        var scene = RaymarchingScene(
            root: builder(),
            skyColor: .cornflowerBlue,
            materialIdMap: materials
        )
        var ids = ElementIdFactory()
        scene.attributeIds(&ids)

        return scene
    }
}
