import SwiftBlend2D
#if canImport(Geometria)
import Geometria
#endif

/// Base type for renderer scenes.
public struct Scene<T: Element>: SceneType {
    public var root: T
    public var skyColor: BLRgba32
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector
    public var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)

    /// Mapping of materials and their IDs.
    public var materialIdMap: MaterialMap

    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        root.attributeIds(&idFactory)
    }

    /// Returns an item on this scene matching a specified id, across all elements
    /// on the scene.
    /// Returns `nil` if no element with the given ID was found on this scene.
    public func queryScene(id: Element.Id) -> Element? {
        root.queryScene(id: id)
    }

    /// Returns the material associated with a given element ID.
    public func material(id: MaterialId) -> Material? {
        materialIdMap[id]
    }

    /// Gets the full material map for this scene type
    public func materialMap() -> MaterialMap {
        materialIdMap
    }

    /// Walks a visitor through this scene's elements.
    public func walk<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        root.accept(visitor)
    }
}
