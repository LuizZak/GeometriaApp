import SwiftBlend2D
#if canImport(Geometria)
import Geometria
#endif

public struct RaytracingScene<T: RaytracingElement>: RaytracingSceneType {
    public var root: T
    
    // Sky color for pixels that don't intersect with geometry
    public var skyColor: BLRgba32 = .cornflowerBlue
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector
    public var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)

    /// Mapping of materials and their IDs.
    public var materialIdMap: MaterialMap
    
    @inlinable
    public func intersect(ray: RRay3D, ignoring: RayIgnore = .none) -> RayHit? {
        root.raycast(query: 
            .init(
                ray: ray, 
                ignoring: ignoring
            )
        ).lastHit
    }
    
    /// Returns a list of all geometry that intersects a given ray.
    @inlinable
    public func intersectAll(ray: RRay3D, ignoring: RayIgnore = .none) -> SortedRayHits {
        var hits: SortedRayHits = []

        root.raycast(query: .init(ray: ray, ignoring: ignoring), results: &hits)

        return hits
    }
    
    @inlinable
    public mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        root.attributeIds(&idFactory)
    }

    /// Returns an item on this scene matching a specified id, across all elements
    /// on the scene.
    /// Returns `nil` if no element with the given ID was found on this scene.
    @inlinable
    public func queryScene(id: Int) -> Element? {
        root.queryScene(id: id)
    }

    /// Returns the material associated with a given element ID.
    @inlinable
    public func material(id: Int) -> Material? {
        materialIdMap[id]
    }

    /// Gets the full material map for this scene type
    @inlinable
    public func materialMap() -> MaterialMap {
        materialIdMap
    }

    /// Walks a visitor through this scene's elements.
    public func walk<Visitor: ElementVisitor>(_ visitor: Visitor) -> Visitor.ResultType {
        root.accept(visitor)
    }
}

extension RaytracingElementBuilder {
    @inlinable
    public static func makeScene<T>(
        skyColor: BLRgba32,
        materials: MaterialMap,
        @RaytracingElementBuilder _ builder: () -> T
    ) -> RaytracingScene<T> where T: RaytracingElement {
        
        var scene = RaytracingScene<T>(
            root: builder(),
            skyColor: .cornflowerBlue,
            materialIdMap: materials
        )
        var ids = ElementIdFactory()
        scene.attributeIds(&ids)

        return scene
    }
}
