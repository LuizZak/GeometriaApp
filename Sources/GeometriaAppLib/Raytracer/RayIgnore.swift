import Geometria

/// Specifies ignore patterns for geometries during raytracing.
enum RayIgnore {
    /// Include all geometries in ray intersection, i.e. ignore none.
    case none
    
    /// Ignores the attached geometry object fully.
    case full(SceneGeometry)
    
    /// Ignores entrance rays for a given geometry object.
    case entrance(SceneGeometry, minimumRayLengthSquared: Double = 0.0)
    
    /// Ignores exit rays for a given geometry object.
    case exit(SceneGeometry, minimumRayLengthSquared: Double = 0.0)
    
    /// Returns `true` iff this ``RayIgnore`` instance is `.full` case, with the
    /// given geometry assigned.
    func shouldIgnoreFully(sceneGeometry: SceneGeometry) -> Bool {
        switch self {
        case .full(let geometry):
            return geometry === sceneGeometry
        case .none, .entrance, .exit:
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
    /// (entrance) or singular point of intersection is returned, if no entrance
    /// is available, the exit point is returned, and if no exit point is
    /// available `nil` is then ultimately returned.
    func computePointNormalOfInterest<Vector>(sceneGeometry: SceneGeometry,
                                              intersection: ConvexLineIntersection<Vector>) -> PointNormal<Vector>? {
        
        switch self {
        case .none:
            break
            
        case .full(let geometry):
            if geometry === sceneGeometry {
                return nil
            }
            
        case .entrance(let geometry, _):
            if geometry !== sceneGeometry {
                break
            }
            
            if let exit = intersection.exitPoint {
                return exit
            } else {
                return nil
            }
            
        case .exit(let geometry, _):
            if geometry !== sceneGeometry {
                break
            }
            
            if let entrance = intersection.entrancePoint {
                return entrance
            } else {
                return nil
            }
        }
        
        return intersection.entrancePoint ?? intersection.exitPoint
    }
}

private extension ConvexLineIntersection {
    var entrancePoint: PointNormal<Vector>? {
        switch self {
        case .enter(let e), .singlePoint(let e), .enterExit(let e, _):
            return e
        default:
            return nil
        }
    }
    var exitPoint: PointNormal<Vector>? {
        switch self {
        case .exit(let e), .singlePoint(let e), .enterExit(_, let e):
            return e
        default:
            return nil
        }
    }
}
