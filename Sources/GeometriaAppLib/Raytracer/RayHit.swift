// import Geometria

struct RayHit: Equatable {
    /// Convenience for `pointOfInterest.point`
    @_transparent
    var point: RVector3D {
        return pointOfInterest.point
    }
    /// Convenience for `pointOfInterest.normal`
    @_transparent
    var normal: RVector3D {
        return pointOfInterest.normal
    }
    
    /// The point-of-interest for the intersection, which is one of the point
    /// normals in ``intersection``, according to the ``RayIgnore`` that was used
    /// during the raycasting invocation where this ray hit was created.
    var pointOfInterest: PointNormal<RVector3D>
    var hitDirection: HitDirection
    var material: MaterialId?
    var id: Int
    
    @_transparent
    init(pointOfInterest: PointNormal<RVector3D>,
         hitDirection: HitDirection,
         material: MaterialId?,
         id: Int) {
        
        self.pointOfInterest = pointOfInterest
        self.hitDirection = hitDirection
        self.material = material
        self.id = id
    }
    
    @_transparent
    init?(findingPointOfInterestOf rayIgnore: RayIgnore,
          intersection: RConvexLineResult3D,
          material: MaterialId?,
          id: Int) {
        
        guard let poi = rayIgnore.computePointNormalOfInterest(id: id, intersection: intersection) else {
            return nil
        }
        
        self.init(pointOfInterest: poi.point, hitDirection: poi.direction, material: material, id: id)
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
        
        return RayHit(pointOfInterest: poi.point, hitDirection: poi.direction, material: material, id: id)
    }

    /// Translates the components of this ray hit, returning a new hit that is 
    /// shifted in space by an ammout specified by `vector`.
    @_transparent
    func translated(by vector: RVector3D) -> RayHit {
        var hit = self
        
        hit.pointOfInterest.point += vector

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
