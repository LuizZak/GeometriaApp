import SwiftBlend2D

struct RaymarchingScene<T: RaymarchingElement>: RaymarchingSceneType {
    var root: T
    var skyColor: BLRgba32
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)

    /// Mapping of materials and their IDs.
    var materialIdMap: MaterialMap

    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        root.signedDistance(to: point, current: current)
    }
    
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        root.attributeIds(&idFactory)
    }

    /// Returns an item on this scene matching a specified id, across all elements
    /// on the scene.
    /// Returns `nil` if no element with the given ID was found on this scene.
    func queryScene(id: Int) -> Element? {
        root.queryScene(id: id)
    }

    /// Returns the material associated with a given element ID.
    func material(id: Int) -> Material? {
        materialIdMap[id]
    }

    /// Gets the full material map for this scene type
    func materialMap() -> MaterialMap {
        materialIdMap
    }

    /// Walks a visitor through this scene's elements.
    func walk<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        root.accept(visitor)
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
