// import Geometria

struct RayHit: Equatable {
    /// The identifier for the element that was hit.
    var id: Int
    var pointNormal: PointNormal<RVector3D>
    var hitDirection: HitDirection
    var material: MaterialId?
    
    /// Convenience for `pointNormal.point`
    @_transparent
    var point: RVector3D {
        return pointNormal.point
    }
    /// Convenience for `pointNormal.normal`
    @_transparent
    var normal: RVector3D {
        return pointNormal.normal
    }
    
    @_transparent
    init(id: Int,
         pointNormal: PointNormal<RVector3D>,
         hitDirection: HitDirection,
         material: MaterialId?) {
        
        self.id = id
        self.pointNormal = pointNormal
        self.hitDirection = hitDirection
        self.material = material
    }

    @_transparent
    init(id: Int,
         pointOfInterest: (point: RPointNormal3D, hitDirection: RayHit.HitDirection),
         material: MaterialId?) {
        
        self.id = id
        self.pointNormal = pointOfInterest.point
        self.hitDirection = pointOfInterest.hitDirection
        self.material = material
    }
    
    @_transparent
    init?(findingPointOfInterestOf rayIgnore: RayIgnore,
          intersection: RConvexLineResult3D,
          material: MaterialId?,
          id: Int) {
        
        guard let poi = rayIgnore.computePointNormalOfInterest(id: id, intersection: intersection) else {
            return nil
        }
        
        self.init(id: id, pointNormal: poi.point, hitDirection: poi.hitDirection, material: material)
    }
    
    /// Computes a new ``RayHit`` from the parameters of this instance, while
    /// assigning the point-of-interest of a given ``RayIgnore`` instance.
    ///
    /// Returns `nil` if ``RayIgnore/computePointNormalOfInterest`` returns `nil`
    @_transparent
    func assignPointOfInterest(from rayIgnore: RayIgnore, intersection: RConvexLineResult3D) -> RayHit? {
        guard let poi = rayIgnore.computePointNormalOfInterest(
            id: id,
            intersection: intersection
        ) else {
            return nil
        }
        
        return RayHit(id: id, pointNormal: poi.point, hitDirection: poi.hitDirection, material: material)
    }

    /// Translates the components of this ray hit, returning a new hit that is 
    /// shifted in space by an ammout specified by `vector`.
    @_transparent
    func translated(by vector: RVector3D) -> RayHit {
        var hit = self
        
        hit.pointNormal.point += vector

        return hit
    }
    
    /// Specifies where the ray hit the geometry.
    enum HitDirection {
        /// Ray hit the geometry from the inside
        case inside
        /// Ray hit the geometry from the outside
        case outside
    }
}
