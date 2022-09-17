/// Specifies ignore patterns for geometries during raytracing.
enum RayIgnore: Equatable {
    /// Include all geometries in ray intersection, i.e. ignore none.
    case none
    
    /// Ignores the attached geometry object fully.
    case full(id: Int)
    
    /// Ignores entrance rays for a given geometry object.
    ///
    /// `minimumRayLengthSquared` indicates how far the ray must have traveled
    /// before exits on the same geometry are also not ignored.
    case entrance(id: Int, minimumRayLengthSquared: Double = 0.0)
    
    /// Ignores exit rays for a given geometry object.
    ///
    /// `minimumRayLengthSquared` indicates how far the ray must have traveled
    /// before entrances on the same geometry are also not ignored.
    case exit(id: Int, minimumRayLengthSquared: Double = 0.0)

    /// A ray ignore that only affects a single ID, and all other IDs are
    /// ignored.
    indirect case allButSingleId(id: Int, RayIgnore)
    
    /// Returns `true` iff this ``RayIgnore`` instance is `.full` case, with the
    /// given geometry assigned.
    func shouldIgnoreFully(id: Int) -> Bool {
        switch self {
        case .full(let geoId):
            return geoId == id

        case let .allButSingleId(geoId, ignore):
            if geoId != id {
                return true
            }

            return ignore.shouldIgnoreFully(id: geoId)

        case .none, .entrance, .exit:
            return false
        }
    }

    /// Returns `true` if this ``RayIgnore`` is configured to ignore a particular
    /// ray hit configuration based on its id, hit direction, and distance traveled
    /// by ray before the hit.
    func shouldIgnore(hit: RayHit, rayStart: RVector3D) -> Bool {
        switch self {
        case .full(let geoId):
            return geoId == hit.id
        
        case .entrance(let geoId, let minLen):
            if geoId != hit.id {
                return false
            }
            if rayStart.distanceSquared(to: hit.point) < minLen {
                return true
            }

            return hit.hitDirection == .outside || hit.hitDirection == .singlePoint
        
        case .exit(let geoId, let minLen):
            if geoId != hit.id {
                return false
            }
            if rayStart.distanceSquared(to: hit.point) < minLen {
                return true
            }

            return hit.hitDirection == .inside || hit.hitDirection == .singlePoint

        case let .allButSingleId(geoId, ignore):
            if geoId != hit.id {
                return true
            }

            return ignore.shouldIgnore(hit: hit, rayStart: rayStart)

        case .none:
            return false
        }
    }
    
    /// Using a given geometry intersection result, specified which of the
    /// points on the intersection is the point-of-interest for the intersection.
    ///
    /// Returns `nil` in case none of the available intersection points is of
    /// interest, or if this ``RayIgnore`` rule instance ignores the only
    /// available intersection.
    ///
    /// For most intersections where the geometry is not ignored, the first
    /// (entrance) or singular point of intersection is returned; if no entrance
    /// is available, the exit point is returned, and if no exit point is
    /// available still, `nil` is then ultimately returned.
    func computePointNormalOfInterest(
        id: Int,
        intersection: RConvexLineResult3D,
        rayStart: RVector3D
    ) -> (point: RPointNormal3D, hitDirection: RayHit.HitDirection)? {
        
        let inter = computePointNormalsOfInterest(
            id: id,
            intersection: intersection,
            rayStart: rayStart
        )

        switch inter {
        case .enter(let pn), .enterExit(let pn, _):
            return (pn, .outside)
        case .exit(let pn):
            return (pn, .inside)
        case .singlePoint(let pn):
            return (pn, .singlePoint)
        case .noIntersection, .contained:
            return nil
        }
    }

    /// Using a given geometry intersection result, specified which of the
    /// points on the intersection are the points-of-interest for the intersection.
    ///
    /// Returns an empty array in case none of the available intersection points 
    /// are of interest, or if this ``RayIgnore`` rule instance ignores the only
    /// available intersection.
    func computePointNormalsOfInterest(
        id: Int,
        intersection: RConvexLineResult3D,
        rayStart: RVector3D
    ) -> RConvexLineResult3D {
        
        // Pre-check before looking into each point normal
        switch self {
        case .none:
            return intersection

        case let .allButSingleId(geoId, ignore):
            if geoId == id {
                return ignore.computePointNormalsOfInterest(
                    id: id,
                    intersection: intersection,
                    rayStart: rayStart
                )
            }

            return .noIntersection

        case .full(let geoId):
            if id == geoId {
                return .noIntersection
            }
            
            return intersection

        default:
            break
        }
        
        if intersection.entrancePoint == nil && intersection.exitPoint == nil {
            return .noIntersection
        }
        
        let isSinglePoint: Bool
        if case .singlePoint = intersection {
            isSinglePoint = true
        } else {
            isSinglePoint = false
        }
        
        switch self {
        // Ignore entrances
        case .entrance(id, let minDist):
            if isSinglePoint {
                break
            }
            
            if let exit = intersection.exitPoint, rayStart.distanceSquared(to: exit.point) > minDist {
                return .exit(exit)
            }
        
        // Ignore exits
        case .exit(id, let minDist):
            if isSinglePoint {
                break
            }
            
            if let enter = intersection.entrancePoint, rayStart.distanceSquared(to: enter.point) > minDist {
                return .enter(enter)
            }
            
        default:
            return intersection
        }

        return .noIntersection
    }
}

private extension RConvexLineResult3D {
    var entrancePoint: RPointNormal3D? {
        switch self {
        case .enter(let e), .singlePoint(let e), .enterExit(let e, _):
            return e
        default:
            return nil
        }
    }

    var exitPoint: RPointNormal3D? {
        switch self {
        case .exit(let e), .singlePoint(let e), .enterExit(_, let e):
            return e
        default:
            return nil
        }
    }
}
