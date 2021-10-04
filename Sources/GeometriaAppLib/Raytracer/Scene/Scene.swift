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
            RayQuery(ray: ray,
                             rayMagnitudeSquared: .infinity,
                             lineSegment: .init(start: ray.start, end: ray.start),
                             lastHit: nil,
                             ignoring: ignoring)
        
        var index = 0
        while index < geometries.count {
            defer { index += 1 }
            guard !ignoring.shouldIgnoreFully(id: geometries[index].id) else {
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
        
        for geo in geometries where !ignoring.shouldIgnoreFully(id: geo.id) {
            if let hit = geo.doRayCast(ray: ray, ignoring: ignoring) {
                hits.append(hit)
            }
        }
        
        return hits
    }
}

struct RayQuery {
    var ray: RRay3D
    
    var rayAABB: RAABB3D?
    
    /// Current magnitude of ray's hit point. Is `.infinity` for newly casted
    /// rays that did not intersect geometry yet.
    var rayMagnitudeSquared: Double
    
    /// If `rayMagnitudeSquared` is not `.infinity`, returns a line segment
    /// that represents the current magnitude of the ray.
    ///
    /// If `rayMagnitudeSquared == .infinity`, the result is undefined.
    var lineSegment: RLineSegment3D
    
    var lastHit: RayHit?
    
    var ignoring: RayIgnore
    
    func intersect<Convex: Convex3Type>(_ convex: Convex) -> ConvexLineIntersection<RVector3D> where Convex.Vector == RVector3D {
            rayMagnitudeSquared.isFinite
                ? convex.intersection(with: lineSegment)
                : convex.intersection(with: ray)
    }
    
    func withHit(_ rayHit: RayHit) -> RayQuery {
        let point = rayHit.point
        let magnitudeSquared = point.distanceSquared(to: ray.start)
        
        let lineSegment =
        RLineSegment3D(
            start: ray.start,
            end: ray.projectedMagnitude(magnitudeSquared.squareRoot())
        )
        
        let newAABB = RAABB3D(minimum: RVector3D.pointwiseMin(ray.start, point),
                              maximum: RVector3D.pointwiseMax(ray.start, point))
        
        return RayQuery(ray: ray,
                                rayAABB: newAABB,
                                rayMagnitudeSquared: magnitudeSquared,
                                lineSegment: lineSegment,
                                lastHit: rayHit,
                                ignoring: ignoring)
    }
    
    func withHit(magnitudeSquared: Double,
                 point: RVector3D,
                 normal: RVector3D,
                 intersection: ConvexLineIntersection<RVector3D>,
                 id: Int) -> RayQuery {
        
        let hit = RayHit(pointOfInterest: .init(point: point, normal: normal),
                         intersection: intersection,
                         id: id)
        
        return withHit(hit)
    }
}
