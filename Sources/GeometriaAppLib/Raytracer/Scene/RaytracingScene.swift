import SwiftBlend2D

struct RaytracingScene<T: RaytracingElement>: RaytracingSceneType {
    var root: T
    
    // Sky color for pixels that don't intersect with geometry
    var skyColor: BLRgba32 = .cornflowerBlue
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)
    
    @inlinable
    func intersect(ray: RRay3D, ignoring: RayIgnore = .none) -> RayHit? {
        root.raycast(query: 
            .init(
                ray: ray, 
                ignoring: ignoring
            )
        ).lastHit
    }
    
    /// Returns a list of all geometry that intersects a given ray.
    func intersectAll(ray: RRay3D, ignoring: RayIgnore = .none) -> [RayHit] {
        var hits: [RayHit] = []

        root.raycast(query: .init(ray: ray, ignoring: ignoring), results: &hits)

        return hits
    }
    
    mutating func attributeIds(_ idFactory: inout ElementIdFactory) {
        root.attributeIds(&idFactory)
    }

    /// Returns an item on this scene matching a specified id, across all elements
    /// on the scene.
    /// Returns `nil` if no element with the given ID was found on this scene.
    func queryScene(id: Int) -> RaytracingElement? {
        root.queryScene(id: id) as? RaytracingElement
    }
}

extension RaytracingElementBuilder {
    static func makeScene<T>(skyColor: BLRgba32, @RaytracingElementBuilder _ builder: () -> T) -> RaytracingScene<T> where T: RaytracingElement {
        var scene = RaytracingScene<T>(root: builder(), skyColor: .cornflowerBlue)
        var ids = ElementIdFactory()
        scene.attributeIds(&ids)

        return scene
    }
}
