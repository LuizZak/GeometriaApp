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
    
    @_transparent
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
    var material: Material?
    var id: Int
    
    @_transparent
    init(pointOfInterest: PointNormal<RVector3D>,
         intersection: RConvexLineResult3D,
         material: Material?,
         id: Int) {
        
        self.pointOfInterest = pointOfInterest
        self.intersection = intersection
        self.material = material
        self.id = id
    }
    
    @_transparent
    init?(findingPointOfInterestOf rayIgnore: RayIgnore,
          intersection: RConvexLineResult3D,
          material: Material?,
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
    @_transparent
    func assignPointOfInterest(from rayIgnore: RayIgnore) -> RayHit? {
        guard let poi = rayIgnore.computePointNormalOfInterest(
            id: id,
            intersection: intersection
        ) else {
            return nil
        }
        
        return RayHit(pointOfInterest: poi, intersection: intersection, material: material, id: id)
    }

    /// Translates the components of this ray hit, returning a new hit that is 
    /// shifted in space by an ammout specified by `vector`.
    @_transparent
    func translated(by vector: RVector3D) -> RayHit {
        var hit = self
        
        hit.intersection = hit.intersection.mappingPointNormals { (pn, _) in
            var pn = pn
            pn.point += vector
            return pn
        }
        
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
