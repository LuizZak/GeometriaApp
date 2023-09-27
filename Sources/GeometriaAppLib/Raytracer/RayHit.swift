#if canImport(Geometria)
import Geometria
#endif

public struct RayHit: Equatable {
    /// The identifier for the element that was hit.
    public var id: Int

    /// The point at which the intersection occurred.
    public var pointNormal: PointNormal<RVector3D>

    /// Whether the hit came from an internal, external, or flat-plane direction.
    public var hitDirection: HitDirection

    /// The squared distance from the origin point of the ray to `pointNormal.point`,
    /// computed at the hit point.
    public var distanceSquared: Double

    /// The ID of the material that was hit, computed at the hit point.
    public var material: MaterialId?
    
    /// Convenience for `pointNormal.point`
    @_transparent
    public var point: RVector3D {
        return pointNormal.point
    }
    /// Convenience for `pointNormal.normal`
    @_transparent
    public var normal: RVector3D {
        return pointNormal.normal
    }

    /// Returns a copy of this ray hit, but with an inverted `hitDirection` value.
    public var withInvertedHitDirection: Self {
        return .init(
            id: id,
            pointNormal: pointNormal,
            hitDirection: hitDirection.inverted,
            distanceSquared: distanceSquared,
            material: material
        )
    }
    
    @_transparent
    public init(
        id: Int,
        pointNormal: PointNormal<RVector3D>,
        hitDirection: HitDirection,
        distanceSquared: Double,
        material: MaterialId?
    ) {
        
        self.id = id
        self.pointNormal = pointNormal
        self.hitDirection = hitDirection
        self.distanceSquared = distanceSquared
        self.material = material
    }

    @_transparent
    public init(
        id: Int,
        pointOfInterest: (point: RPointNormal3D, hitDirection: RayHit.HitDirection),
        distanceSquared: Double,
        material: MaterialId?
    ) {
        
        self.id = id
        self.pointNormal = pointOfInterest.point
        self.hitDirection = pointOfInterest.hitDirection
        self.distanceSquared = distanceSquared
        self.material = material
    }
    
    @_transparent
    public init?(
        findingPointOfInterestOf rayIgnore: RayIgnore,
        intersection: RConvexLineResult3D,
        rayStart: RVector3D,
        material: MaterialId?,
        id: Int
    ) {
        
        guard let poi = rayIgnore.computePointNormalOfInterest(
            id: id,
            intersection: intersection,
            rayStart: rayStart
        ) else {
            return nil
        }
        
        self.init(
            id: id,
            pointNormal: poi.point,
            hitDirection: poi.hitDirection,
            distanceSquared: poi.point.point.distanceSquared(to: rayStart),
            material: material
        )
    }
    
    /// Computes a new ``RayHit`` from the parameters of this instance, while
    /// assigning the point-of-interest of a given ``RayIgnore`` instance.
    ///
    /// Returns `nil` if ``RayIgnore/computePointNormalOfInterest`` returns `nil`
    @_transparent
    public func assignPointOfInterest(
        from rayIgnore: RayIgnore,
        intersection: RConvexLineResult3D,
        rayStart: RVector3D,
        distanceSquared: Double
    ) -> RayHit? {

        guard let poi = rayIgnore.computePointNormalOfInterest(
            id: id,
            intersection: intersection,
            rayStart: rayStart
        ) else {
            return nil
        }
        
        return RayHit(
            id: id,
            pointNormal: poi.point,
            hitDirection: poi.hitDirection,
            distanceSquared: poi.point.point.distanceSquared(to: rayStart),
            material: material
        )
    }

    /// Translates the components of this ray hit, returning a new hit that is 
    /// shifted in space by an amount specified by `vector`.
    ///
    /// - note: `distanceSquared` is relative to the original ray origin and
    /// cannot be recomputed by this method alone, and thus is left unchanged.
    /// This may lead to incorrect results depending on how the `distanceSquared`
    /// of this structure is used post-translation.
    public func translated(by vector: RVector3D) -> RayHit {
        var hit = self
        
        hit.pointNormal.point += vector

        return hit
    }

    /// Uniformly scales the components of this ray hit, returning a new hit that
    /// is scaled in space around a given center point by an amount specified by
    /// `factor`.
    ///
    /// - note: `distanceSquared` is relative to the original ray origin and
    /// cannot be recomputed by this method alone, and thus is left unchanged.
    /// This may lead to incorrect results depending on how the `distanceSquared`
    /// of this structure is used post-scaling.
    public func scaledBy(_ factor: Double, around center: RVector3D) -> Self {
        var hit = self

        // Since scaling is uniform, we don't need to scale the normal of the
        // hit information.
        hit.pointNormal.point = (pointNormal.point - center) * factor + center

        return hit
    }
    
    /// Rotates the components of this ray hit, returning a new ray hit that
    /// is rotated in space around the given center point by a given rotational
    /// matrix.
    ///
    /// - note: `distanceSquared` is relative to the original ray origin and
    /// cannot be recomputed by this method alone, and thus is left unchanged.
    /// This may lead to incorrect results depending on how the `distanceSquared`
    /// of this structure is used post-rotation.
    public func rotatedBy(_ matrix: RRotationMatrix3D, around center: RVector3D) -> Self {
        var hit = self
        
        hit.pointNormal.point =
            hit.pointNormal
                .point
                .rotatedBy(matrix, around: center)
        
        hit.pointNormal.normal =
            hit.pointNormal
                .normal
                .rotatedBy(matrix, around: .zero)
                .normalized()
        
        return hit
    }

    /// Returns a ray hit ignore that ignores this particular hit in subsequent
    /// raytracing queries.
    ///
    /// Ray hits with this ignore may fail to yield expected results, as hits are
    /// not discretely identified and can only be ignored based on loose
    /// inner/outer hits and geometry ID.
    public func rayIgnoreForHit(minimumRayLengthSquared: Double = 0.0) -> RayIgnore {
        switch hitDirection {
        case .inside:
            return .entrance(id: id, minimumRayLengthSquared: minimumRayLengthSquared)

        case .outside:
            return .exit(id: id, minimumRayLengthSquared: minimumRayLengthSquared)

        case .singlePoint:
            return .full(id: id)
        }
    }
    
    /// Specifies the direction of the ray when it hit the boundaries of 
    /// a geometry.
    public enum HitDirection {
        /// Ray hit the geometry from the inside out
        case inside

        /// Ray hit the geometry from the outside in
        case outside

        /// Ray hit a geometry that is not volumetric, e.g. a plane.
        case singlePoint
        
        /// Returns the opposite hit direction that this value represents.
        ///
        /// Returns `HitDirection.inside` if this value is `.outside`, and
        /// `.outside` if this value is `.inside`.
        ///
        /// `.singlePoint` always maps back into `.singlePoint`.
        public var inverted: Self {
            switch self {
            case .inside:
                return .outside
            case .outside:
                return .inside
            case .singlePoint:
                return .singlePoint
            }
        }
    }
}
