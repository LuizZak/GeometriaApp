import SwiftBlend2D
#if canImport(Geometria)
import Geometria
#endif

public struct AnyRaymarchingScene: SceneType {
    public var root: AnyRaymarchingElement
    public var skyColor: BLRgba32
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector
    public var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)

    /// Mapping of materials and their IDs.
    public var materialIdMap: MaterialMap

    public init(
        root: AnyRaymarchingElement,
        skyColor: BLRgba32,
        sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30),
        materialIdMap: MaterialMap
    ) {
        
        self.root = root
        self.skyColor = skyColor
        self.sunDirection = sunDirection
        self.materialIdMap = materialIdMap
    }

    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        root.attributeIds(&idFactory)
    }

    /// Returns an item on this scene matching a specified id, across all elements
    /// on the scene.
    /// Returns `nil` if no element with the given ID was found on this scene.
    public func queryScene(id: Int) -> Element? {
        root.queryScene(id: id)
    }

    /// Returns the material associated with a given element ID.
    public func material(id: Int) -> Material? {
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

extension AnyRaymarchingScene: RaymarchingSceneType {
    public func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        root.signedDistance(to: point, current: current)
    }

    /// Walks a visitor through this scene's elements.
    public func walk<Visitor: RaymarchingElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        root.accept(visitor)
    }
}
