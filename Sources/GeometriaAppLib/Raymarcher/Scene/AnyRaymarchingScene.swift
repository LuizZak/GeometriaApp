import SwiftBlend2D
#if canImport(Geometria)
import Geometria
#endif

struct AnyRaymarchingScene: SceneType {
    var root: AnyRaymarchingElement
    var skyColor: BLRgba32
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)

    /// Mapping of materials and their IDs.
    var materialIdMap: MaterialMap

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
}

extension AnyRaymarchingScene: RaymarchingSceneType {
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        root.signedDistance(to: point, current: current)
    }

    /// Walks a visitor through this scene's elements.
    func walk<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        root.accept(visitor)
    }
}
