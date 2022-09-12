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
    func withNilHit() -> Self {
        .init(ray: ray, ignoring: ignoring)
    }
    
    @inlinable
    func withHit(_ rayHit: RayHit) -> Self {
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
    func withHit(
        magnitudeSquared: Double,
        id: Int,
        point: RVector3D,
        normal: RVector3D,
        hitDirection: RayHit.HitDirection,
        material: MaterialId
    ) -> Self {
        
        let hit = RayHit(
            id: id,
            pointNormal: .init(point: point, normal: normal),
            hitDirection: hitDirection,
            material: material
        )
        
        return withHit(hit)
    }

    /// Translates the components of this ray query, returning a new ray query
    /// that is shifted in space by an amount specified by `vector`.
    func translated(by vector: RVector3D) -> Self {
        var query = self

        query.ray = self.ray.offsetBy(vector)
        query.rayAABB = self.rayAABB?.offsetBy(vector)
        query.lineSegment = self.lineSegment.offsetBy(vector)
        query.lastHit = self.lastHit?.translated(by: vector)
        
        return query
    }

    /// Uniformly scales the components of this ray query, returning a new ray 
    /// query that is scaled in space around the given center point by an amount 
    /// specified by `factor`.
    func scaled(by factor: Double, around center: RVector3D) -> Self {
        var query = self
        let vector = RVector3D(repeating: factor)

        query.ray = self.ray.withPointsScaledBy(vector, around: center)
        query.rayMagnitudeSquared = self.rayMagnitudeSquared * factor
        query.rayAABB = self.rayAABB?.scaledBy(factor, around: center)
        query.lineSegment = self.lineSegment.withPointsScaledBy(vector, around: center)
        query.lastHit = self.lastHit?.scaledBy(factor, around: center)
        
        return query
    }
    
    /// Rotates the components of this ray query, returning a new ray query that
    /// is rotated in space around the given center point by a given rotational
    /// matrix.
    func rotated(by matrix: RRotationMatrix3D, around center: RVector3D) -> Self {
        var query = self

        query.ray = self.ray.rotated(by: matrix, around: center)
        query.rayAABB = self.rayAABB?.rotated(by: matrix, around: center)
        query.lineSegment = self.lineSegment.rotated(by: matrix, around: center)
        query.lastHit = self.lastHit?.rotated(by: matrix, around: center)
        
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
    func intersect<Convex: Convex3Type>(
        convex geometry: Convex
    ) -> RConvexLineResult3D where Convex.Vector == RVector3D {
        
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
    func intersect<Plane: LineIntersectablePlaneType>(
        plane geometry: Plane
    ) -> RConvexLineResult3D where Plane.Vector == RVector3D {
        
        guard let inter = intersection(plane: geometry) else {
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
    
    func isFullyContained<Convex: Convex3Type>(
        by convex: Convex
    ) -> Bool where Convex.Vector == RVector3D {
        
        if rayMagnitudeSquared.isFinite {
            switch convex.intersection(with: lineSegment) {
            case .contained:
                return true
            default:
                return false
            }
        } else {
            switch convex.intersection(with: ray) {
            case .contained:
                return true
            default:
                return false
            }
        }
    }

    func isFullyContained(by hyperplane: RHyperplane3D) -> Bool {
        if !hyperplane.contains(ray.a) {
            return false
        }

        // Line is parallel: checking for point containment above is enough
        if hyperplane.normal.dot(ray.lineSlope) <= .leastNonzeroMagnitude {
            return true
        }

        guard let mag = hyperplane.unclampedNormalMagnitudeForIntersection(with: ray) else {
            return false
        }

        return mag >= 0.0 && mag * mag <= rayMagnitudeSquared
    }
    
    @_transparent
    private func intersection<Plane: LineIntersectablePlaneType>(
        plane geometry: Plane
    ) -> RVector3D? where Plane.Vector == RVector3D {
        
        rayMagnitudeSquared.isFinite
            ? geometry.intersection(with: lineSegment)
            : geometry.intersection(with: ray)
    }
}

// MARK: RaytracingElement helpers
extension RayQuery {

    // MARK: Convex3Type

    func intersecting<Convex: Convex3Type>(
        id: Int,
        material: MaterialId?,
        convex geometry: Convex
    ) -> Self where Convex.Vector == RVector3D {
        
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return self
        }

        let intersection = intersect(convex: geometry)

        guard let hit = RayHit(
            findingPointOfInterestOf: ignoring,
            intersection: intersection,
            rayStart: ray.start,
            material: material,
            id: id
        ) else {
            return self
        }
        
        return self.withHit(hit)
    }

    func intersectAll<Convex: Convex3Type>(
        id: Int,
        material: MaterialId?,
        convex geometry: Convex,
        results: inout [RayHit]
    ) where Convex.Vector == RVector3D {
        
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return
        }

        let intersection = intersect(convex: geometry)
        let pois = ignoring.computePointNormalsOfInterest(
            id: id,
            intersection: intersection,
            rayStart: ray.start
        )

        appendPointsOfInterest(pois, id: id, material: material, to: &results)
    }

    // MARK: LineIntersectablePlaneType

    func intersecting<Plane: LineIntersectablePlaneType>(
        id: Int,
        material: MaterialId?,
        plane geometry: Plane
    ) -> Self where Plane.Vector == RVector3D {
        
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return self
        }

        let intersection = intersect(plane: geometry)
        guard let hit = RayHit(
            findingPointOfInterestOf: ignoring,
            intersection: intersection,
            rayStart: ray.start,
            material: material,
            id: id
        ) else {
            return self
        }

        return self.withHit(hit)
    }

    func intersectAll<Plane: LineIntersectablePlaneType>(
        id: Int,
        material: MaterialId?,
        plane geometry: Plane,
        results: inout [RayHit]
    ) where Plane.Vector == RVector3D {
        
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return
        }
    	
        let intersection = intersect(plane: geometry)
        let pois = ignoring.computePointNormalsOfInterest(
            id: id,
            intersection: intersection,
            rayStart: ray.start
        )

        appendPointsOfInterest(pois, id: id, material: material, to: &results)
    }

    private func appendPointsOfInterest(
        _ intersection: RConvexLineResult3D,
        id: Int,
        material: MaterialId?,
        to results: inout [RayHit]
    ) {
        switch intersection {
        case .enterExit(let enter, let exit):
            results.append(.init(id: id, pointOfInterest: (enter, .outside), material: material))
            results.append(.init(id: id, pointOfInterest: (exit, .inside), material: material))
        
        case .enter(let enter):
            results.append(.init(id: id, pointOfInterest: (enter, .outside), material: material))

        case .exit(let exit):
            results.append(.init(id: id, pointOfInterest: (exit, .inside), material: material))

        case .singlePoint(let point):
            results.append(.init(id: id, pointOfInterest: (point, .singlePoint), material: material))

        case .contained, .noIntersection:
            break
        }
    }
}
