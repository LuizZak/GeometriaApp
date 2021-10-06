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

    /// Scales the components of this ray hit, returning a new hit that is 
    /// scaled in space around a given center point by an ammout specified by 
    /// `factor`.
    @_transparent
    func scaledBy(_ factor: Double, around center: RVector3D) -> Self {
        var hit = self

        // Since scaling is uniform, we don't need to scale the normal of the
        // hit information.
        hit.pointNormal.point = (pointNormal.point - center) * factor + center

        return hit
    }
    
    /// Specifies the direction of the ray when it hit the boundaries of 
    /// a geometry.
    enum HitDirection {
        /// Ray hit the geometry from the inside out
        case inside
        /// Ray hit the geometry from the outside in
        case outside
        
        /// Returns the opposite hit direction that this value represents.
        ///
        /// Returns `HitDirection.inside` if this value is `.outside`, and
        /// `.outside` if this value is `.inside`.
        var inverted: Self {
            switch self {
            case .inside:
                return .outside
            case .outside:
                return .inside
            }
        }
    }
}
