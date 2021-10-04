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
            makeQuery(
                ray: ray, 
                ignoring: ignoring
            )
        ).lastHit
    }
    
    /// Returns a list of all geometry that intersects a given ray.
    func intersectAll(ray: RRay3D, ignoring: RayIgnore = .none) -> [RayHit] {
        var hits: [RayHit] = []

        root.raycast(query: makeQuery(ray: ray, ignoring: ignoring), results: &hits)

        return hits
    }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory) {
        root.attributeIds(&idFactory)
    }

    private func makeQuery(ray: RRay3D, ignoring: RayIgnore) -> RayQuery {
        RayQuery(
            ray: ray,
            rayMagnitudeSquared: .infinity,
            lineSegment: .init(start: ray.start, end: ray.start),
            lastHit: nil,
            ignoring: ignoring
        )
    }
}

extension RaytracingElementBuilder {
    static func makeScene<T>(skyColor: BLRgba32, @RaytracingElementBuilder _ builder: () -> T) -> RaytracingScene<T> where T: RaytracingElement {
        .init(root: builder(), skyColor: .cornflowerBlue)
    }
}
