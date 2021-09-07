import Geometria

struct RayHit {
    /// Convenience for `pointOfInterest.point`
    var point: Vector3D {
        return pointOfInterest.point
    }
    /// Convenience for `pointOfInterest.normal`
    var normal: Vector3D {
        return pointOfInterest.normal
    }
    
    /// The point-of-interest for the intersection, which is one of the point
    /// normals in ``intersection``, according to the ``RayIgnore`` that was used
    /// during the raycasting invocation where this ray hit was created.
    var pointOfInterest: PointNormal<Vector3D>
    var intersection: ConvexLineIntersection<Vector3D>
    var sceneGeometry: SceneGeometry
    
    /// Computes a new ``RayHit`` from the parameters of this instance, while
    /// assigning the point-of-interest of a given ``RayIgnore`` instance.
    ///
    /// Returns `nil` if ``RayIgnore/computePointNormalOfInterest`` returns `nil`
    func assignPointOfInterest(from rayIgnore: RayIgnore) -> RayHit? {
        guard let poi = rayIgnore.computePointNormalOfInterest(
            sceneGeometry: sceneGeometry,
            intersection: intersection
        ) else {
            return nil
        }
        
        return RayHit(pointOfInterest: poi, intersection: intersection, sceneGeometry: sceneGeometry)
    }
}
