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
        
        return RayQuery(
            ray: ray,
            rayAABB: newAABB,
            rayMagnitudeSquared: magnitudeSquared,
            lineSegment: lineSegment,
            lastHit: rayHit,
            ignoring: ignoring
        )
    }
    
    func withHit(magnitudeSquared: Double,
                 point: RVector3D,
                 normal: RVector3D,
                 intersection: RConvexLineResult3D,
                 material: RaytracingMaterial,
                 id: Int) -> RayQuery {
        
        let hit = RayHit(pointOfInterest: .init(point: point, normal: normal),
                         intersection: intersection,
                         material: material,
                         id: id)
        
        return withHit(hit)
    }
}

extension RayQuery {    
    init(ray: RRay3D, ignoring: RayIgnore) {
        self = RayQuery(
            ray: ray,
            rayMagnitudeSquared: .infinity,
            lineSegment: .init(start: ray.start, end: ray.start),
            lastHit: nil,
            ignoring: ignoring
        )
    }

    func intersect<Convex: Convex3Type>(_ geometry: Convex) -> RConvexLineResult3D where Convex.Vector == RVector3D {
        let intersection = 
            rayMagnitudeSquared.isFinite
            ? geometry.intersection(with: lineSegment)
            : geometry.intersection(with: ray)

        switch intersection {
        case .enter(let pt),
             .exit(let pt),
             .enterExit(let pt, _),
             .singlePoint(let pt):
            
            let distSq = pt.point.distanceSquared(to: ray.start)
            if distSq > rayMagnitudeSquared {
                return .noIntersection
            }
            
            return intersection
        default:
            return intersection
        }
    }
    
    func intersect<Plane: LineIntersectablePlaneType>(_ geometry: Plane) -> RConvexLineResult3D where Plane.Vector == RVector3D {
        guard let inter = intersection(geometry) else {
            return .noIntersection
        }
        
        let dSquared = inter.distanceSquared(to: ray.start)
        guard dSquared < rayMagnitudeSquared else {
            return .noIntersection
        }
        
        var normal: RVector3D = geometry.normal
        if normal.dot(ray.direction) > 0 {
            normal = -normal
        }
        
        return .singlePoint(PointNormal(point: inter, normal: normal))
    }
    
    @_transparent
    private func intersection<Plane: LineIntersectablePlaneType>(_ geometry: Plane) -> RVector3D? where Plane.Vector == RVector3D {
        rayMagnitudeSquared.isFinite
            ? geometry.intersection(with: lineSegment)
            : geometry.intersection(with: ray)
    }
}
