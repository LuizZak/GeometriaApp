import SwiftBlend2D

struct Scene {
    // Sky color for pixels that don't intersect with geometry
    var skyColor: BLRgba32 = .cornflowerBlue
    
    var geometries: [SceneGeometry] = []
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)
    
    mutating func addGeometry(_ geometry: SceneGeometry) {
        geometries.append(geometry)
    }
    
    @inlinable
    func intersect(ray: RRay3D, ignoring: RayIgnore = .none) -> RayHit? {
        var result =
            PartialRayResult(ray: ray,
                             rayMagnitudeSquared: .infinity,
                             lastHit: nil,
                             ignoring: ignoring)
        
        var index = 0
        while index < geometries.count {
            defer { index += 1 }
            guard ignoring.shouldIgnoreFully(id: geometries[index].id) else {
                continue
            }
            
            result = geometries[index].doRayCast(partialResult: result)
        }
        
        return result.lastHit
    }
    
    /// Returns a list of all geometry that intersects a given ray.
    @inlinable
    func intersectAll(ray: RRay3D, ignoring: RayIgnore = .none) -> [RayHit] {
        var hits: [RayHit] = []

        var index = 0
        while index < geometries.count {
            defer { index += 1 }
            guard ignoring.shouldIgnoreFully(id: geometries[index].id) else {
                continue
            }
                
            if let hit = geometries[index].doRayCast(ray: ray, ignoring: ignoring) {
                hits.append(hit)
            }
        }
        
        return hits
    }
    
    struct PartialRayResult {
        var ray: RRay3D
        var rayAABB: RAABB3D?
        /// Current magnitude of ray's hit point. Is `.infinity` for newly casted
        /// rays that did not intersect geometry yet.
        var rayMagnitudeSquared: Double
        var lastHit: RayHit?
        var ignoring: RayIgnore
        
        func withHit(_ rayHit: RayHit) -> PartialRayResult {
            let point = rayHit.point
            let magnitudeSquared = point.distanceSquared(to: ray.start)
            
            let newAABB = RAABB3D(minimum: RVector3D.pointwiseMin(ray.start, point),
                                  maximum: RVector3D.pointwiseMax(ray.start, point))
            
            return PartialRayResult(ray: ray,
                                    rayAABB: newAABB,
                                    rayMagnitudeSquared: magnitudeSquared,
                                    lastHit: rayHit,
                                    ignoring: ignoring)
        }
        
        func withHit(magnitudeSquared: Double,
                     point: RVector3D,
                     normal: RVector3D,
                     intersection: ConvexLineIntersection<RVector3D>,
                     sceneGeometry: SceneGeometry) -> PartialRayResult {
            
            let hit = RayHit(pointOfInterest: .init(point: point, normal: normal),
                             intersection: intersection,
                             sceneGeometry: sceneGeometry)
            
            return withHit(hit)
        }
    }
}
