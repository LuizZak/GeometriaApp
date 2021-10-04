// import Geometria

struct RayHit {
    /// Convenience for `pointOfInterest.point`
    var point: RVector3D {
        return pointOfInterest.point
    }
    /// Convenience for `pointOfInterest.normal`
    var normal: RVector3D {
        return pointOfInterest.normal
    }
    
    var hitDirection: HitDirection {
        switch intersection {
        case .exit:
            return .inside
        case .enter, .singlePoint(_):
            return .outside
        case .enterExit(let po, _) where po == pointOfInterest:
            return .outside
        case .enterExit(_, let pi) where pi == pointOfInterest:
            return .inside
        default:
            return .outside
        }
    }
    
    /// The point-of-interest for the intersection, which is one of the point
    /// normals in ``intersection``, according to the ``RayIgnore`` that was used
    /// during the raycasting invocation where this ray hit was created.
    var pointOfInterest: PointNormal<RVector3D>
    var intersection: RConvexLineResult3D
    var material: RaytracingMaterial?
    var id: Int
    
    init(pointOfInterest: PointNormal<RVector3D>,
         intersection: RConvexLineResult3D,
         material: RaytracingMaterial?,
         id: Int) {
        
        self.pointOfInterest = pointOfInterest
        self.intersection = intersection
        self.material = material
        self.id = id
    }
    
    init?(findingPointOfInterestOf rayIgnore: RayIgnore,
          intersection: RConvexLineResult3D,
          material: RaytracingMaterial?,
          id: Int) {
        
        guard let poi = rayIgnore.computePointNormalOfInterest(id: id, intersection: intersection) else {
            return nil
        }
        
        self.init(pointOfInterest: poi, intersection: intersection, material: material, id: id)
    }
    
    /// Computes a new ``RayHit`` from the parameters of this instance, while
    /// assigning the point-of-interest of a given ``RayIgnore`` instance.
    ///
    /// Returns `nil` if ``RayIgnore/computePointNormalOfInterest`` returns `nil`
    func assignPointOfInterest(from rayIgnore: RayIgnore) -> RayHit? {
        guard let poi = rayIgnore.computePointNormalOfInterest(
            id: id,
            intersection: intersection
        ) else {
            return nil
        }
        
        return RayHit(pointOfInterest: poi, intersection: intersection, material: material, id: id)
    }
    
    /// Specifies where the ray hit the geometry.
    enum HitDirection {
        /// Ray hit the geometry from the inside
        case inside
        /// Ray hit the geometry from the outside
        case outside
    }
}
