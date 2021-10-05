struct RayQuery: Equatable {
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

    /// Returns a copy of this query with no hit information attributed.
    @_transparent
    func withNilHit() -> RayQuery {
        .init(ray: ray, ignoring: ignoring)
    }
    
    @inlinable
    func withHit(_ rayHit: RayHit) -> RayQuery {
        let point = rayHit.point
        let magnitudeSquared = point.distanceSquared(to: ray.start)
        
        let lineSegment =
        RLineSegment3D(
            start: ray.start,
            end: ray.projectedMagnitude(magnitudeSquared.squareRoot())
        )
        
        let newAABB = lineSegment.bounds
        
        return RayQuery(
            ray: ray,
            rayAABB: newAABB,
            rayMagnitudeSquared: magnitudeSquared,
            lineSegment: lineSegment,
            lastHit: rayHit,
            ignoring: ignoring
        )
    }

    @_transparent
    func withHit(magnitudeSquared: Double,
                 id: Int,
                 point: RVector3D,
                 normal: RVector3D,
                 hitDirection: RayHit.HitDirection,
                 material: MaterialId) -> RayQuery {
        
        let hit = RayHit(
            id: id,
            pointNormal: .init(point: point, normal: normal),
            hitDirection: hitDirection,
            material: material
        )
        
        return withHit(hit)
    }

    /// Translates the components of this ray query, returning a new ray query
    /// that is shifted in space by an ammout specified by `vector`.
    @_transparent
    func translated(by vector: RVector3D) -> Self {
        var query = self

        query.ray = self.ray.offsetBy(vector)
        query.rayAABB = self.rayAABB?.offsetBy(vector)
        query.lineSegment = self.lineSegment.offsetBy(vector)
        query.lastHit = self.lastHit?.translated(by: vector)
        
        return query
    }
}

extension RayQuery {
    @_transparent
    init(ray: RRay3D, ignoring: RayIgnore) {
        self = RayQuery(
            ray: ray,
            rayMagnitudeSquared: .infinity,
            lineSegment: .init(start: ray.start, end: ray.start),
            lastHit: nil,
            ignoring: ignoring
        )
    }
    
    @inlinable
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
    
    @inlinable
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

// MARK: RaytracingElement helpers
extension RayQuery {

    // MARK: Convex3Type

    func intersecting<Convex: Convex3Type>(id: Int,
                                           material: MaterialId?,
                                           geometry: Convex) -> RayQuery where Convex.Vector == RVector3D {
        
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return self
        }

        let intersection = intersect(geometry)
        guard let hit = RayHit(findingPointOfInterestOf: ignoring,
                               intersection: intersection,
                               material: material,
                               id: id) else {
            return self
        }
        
        return self.withHit(hit)
    }

    func intersectAll<Convex: Convex3Type>(id: Int,
                                           material: MaterialId?,
                                           geometry: Convex,
                                           results: inout [RayHit]) where Convex.Vector == RVector3D {
        
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return
        }

        let intersection = intersect(geometry)
        let pois = ignoring.computePointNormalsOfInterest(id: id, intersection: intersection)

        results.append(contentsOf:
            pois.map {
                .init(
                    id: id,
                    pointOfInterest: $0,
                    material: material
                )
            }
        )
    }

    // MARK: LineIntersectablePlaneType

    func intersecting<Plane: LineIntersectablePlaneType>(
        id: Int,
        material: MaterialId?,
        geometry: Plane) -> RayQuery where Plane.Vector == RVector3D {
        
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return self
        }

        let intersection = intersect(geometry)
        guard let hit = RayHit(findingPointOfInterestOf: ignoring,
                               intersection: intersection,
                               material: material,
                               id: id) else {
            return self
        }
        
        return self.withHit(hit)
    }

    func intersectAll<Plane: LineIntersectablePlaneType>(
        id: Int,
        material: MaterialId?,
        geometry: Plane,
        results: inout [RayHit]) where Plane.Vector == RVector3D {
        
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return
        }
    	
        let intersection = intersect(geometry)
        let pois = ignoring.computePointNormalsOfInterest(id: id, intersection: intersection)

        results.append(contentsOf:
            pois.map {
                .init(
                    id: id,
                    pointOfInterest: $0,
                    material: material
                )
            }
        )
    }
}
