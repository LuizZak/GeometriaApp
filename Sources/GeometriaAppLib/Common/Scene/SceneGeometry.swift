import blend2d

// TODO: Split raytracing and distance function components into separate types
// TODO: to try to clean up this implementation.

final class SceneGeometry {
    private var _doRayCast: (_ rayInfo: RayInfo) -> ConvexLineIntersection<RVector3D>
    private var _signedDistanceFunction: (_ point: RVector3D, _ minDistance: Double) -> Double
    var id: Int
    var geometry: GeometricType
    var bounds: AABB3<RVector3D>?
    var boundingSphere: RSphere3D?
    var material: Material
    
    init(id: Int, bumpySphere: Sphere3<RVector3D>, material: Material) {
        self.id = id
        self.bounds = bumpySphere.bounds
        self.material = material
        self.geometry = bumpySphere
        
        // TODO: Implement bumpiness
        _signedDistanceFunction = { (vec, _) in
            bumpySphere.signedDistance(to: vec)
        }
        
        _doRayCast = { rayInfo in
            var intersection = bumpySphere.intersection(with: rayInfo.ray)
            intersection = intersection
                .mappingPointNormals { (pt, _) in
                    let distSq = pt.point.distanceSquared(to: rayInfo.ray.start)
                    if distSq > rayInfo.rayMagnitudeSquared {
                        return pt
                    }
                    
                    let diff = (pt.point - bumpySphere.center)
                    let elev = diff.elevation
                    let azim = diff.azimuth
                    
                    let perlinRatio = 1.0
                    let perlinAtten = 40.0
                    var paz = PerlinGenerator.global.perlinNoise(x: elev / perlinRatio, y: azim / perlinRatio) / perlinAtten
                    var pel = PerlinGenerator.global.perlinNoise(x: azim / perlinRatio, y: elev / perlinRatio) / perlinAtten
                    if paz > .pi {
                        paz -= .pi
                    } else if paz < -.pi {
                        paz += .pi
                    }
                    if pel > .pi / 2 {
                        pel = .pi / 2 - pel
                    } else if pel < -.pi / 2 {
                        pel = .pi / 2 + pel
                    }
                    
                    let sph = SphereCoordinates<Double>(azimuth: azim + paz, elevation: elev + pel)
                    let sphereBulge = bumpySphere.expanded(by: 5.0)
                    let normalEnd = sphereBulge.projectOut(sph)
                    
                    let normal = (normalEnd - pt.point).normalized()
                    
                    return PointNormal(point: pt.point, normal: normal)
                }
            
            switch intersection {
            case .enter(let pt),
                 .exit(let pt),
                 .enterExit(let pt, _),
                 .singlePoint(let pt):
                
                let distSq = pt.point.distanceSquared(to: rayInfo.ray.start)
                if distSq > rayInfo.rayMagnitudeSquared {
                    return .noIntersection
                }
                
                return intersection
            default:
                return intersection
            }
        }
    }
    
    init<C: ConvexType & SignedDistanceMeasurableType & BoundableType>(id: Int, convex: C, material: Material, useBoundSphere: Bool) where C.Vector == RVector3D {
        self.id = id

        let bounds = convex.bounds
        
        self.bounds = bounds
        self.material = material
        self.geometry = convex
        
        if useBoundSphere {
            let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
            
            _signedDistanceFunction = { (vec, minDist) in
                // Do bounds check before passing down distance function
                if sphere.signedDistance(to: vec) > minDist {
                    return minDist
                }

                return convex.signedDistance(to: vec)
            }
        } else {
            _signedDistanceFunction = { (vec, minDist) in
                convex.signedDistance(to: vec)
            }
        }
        
        _doRayCast = { rayInfo in
            let intersection = convex.intersection(with: rayInfo.ray)
            switch intersection {
            case .enter(let pt),
                 .exit(let pt),
                 .enterExit(let pt, _),
                 .singlePoint(let pt):
                
                let distSq = pt.point.distanceSquared(to: rayInfo.ray.start)
                if distSq > rayInfo.rayMagnitudeSquared {
                    return .noIntersection
                }
                
                return intersection
            default:
                return intersection
            }
        }
    }
    
    init<C: Convex3Type & SignedDistanceMeasurableType & BoundableType>(id: Int, convex3 convex: C, material: Material, useBoundSphere: Bool) where C.Vector == RVector3D {
        self.id = id

        let bounds = convex.bounds
        
        self.bounds = bounds
        self.material = material
        self.geometry = convex
        
        if useBoundSphere && convex is AABB<RVector3D> {
            let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
            
            _signedDistanceFunction = { (vec, minDist) in
                // Do bounds check before passing down distance function
                if sphere.signedDistance(to: vec) > minDist {
                    return minDist
                }

                return convex.signedDistance(to: vec)
            }
        } else {
            _signedDistanceFunction = { (vec, minDist) in
                convex.signedDistance(to: vec)
            }
        }
        
        _doRayCast = { rayInfo in
            let intersection = convex.intersection(with: rayInfo.ray)
            switch intersection {
            case .enter(let pt),
                 .exit(let pt),
                 .enterExit(let pt, _),
                 .singlePoint(let pt):
                
                let distSq = pt.point.distanceSquared(to: rayInfo.ray.start)
                if distSq > rayInfo.rayMagnitudeSquared {
                    return .noIntersection
                }
                
                return intersection
            default:
                return intersection
            }
        }
    }
    
    init<P: LineIntersectablePlaneType & BoundableType & SignedDistanceMeasurableType>(id: Int, boundedPlane: P, material: Material) where P.Vector == RVector3D {
        self.id = id

        let bounds = boundedPlane.bounds
        
        self.bounds = bounds
        self.material = material
        self.geometry = boundedPlane
        
        let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
        
        _signedDistanceFunction = { (vec, minDist) in
            // Do bounds check before passing down distance function
            if sphere.signedDistance(to: vec) > minDist {
                return minDist
            }
            
            return boundedPlane.signedDistance(to: vec)
        }
        
        _doRayCast = { rayInfo in
            guard let inter = boundedPlane.intersection(with: rayInfo.ray) else {
                return .noIntersection
            }
            
            let dSquared = inter.distanceSquared(to: rayInfo.ray.start)
            guard dSquared < rayInfo.rayMagnitudeSquared else {
                return .noIntersection
            }
            
            var normal: RVector3D = boundedPlane.normal
            if normal.dot(rayInfo.ray.direction) > 0 {
                normal = -normal
            }
            
            return .singlePoint(PointNormal(point: inter, normal: normal))
        }
    }
    
    init<P: LineIntersectablePlaneType & SignedDistanceMeasurableType>(id: Int, plane: P, material: Material) where P.Vector == RVector3D {
        self.id = id

        self.material = material
        self.geometry = plane
        
        _signedDistanceFunction = { (vec, _) in
            plane.signedDistance(to: vec)
        }
        
        _doRayCast = { rayInfo in
            guard let inter = plane.intersection(with: rayInfo.ray) else {
                return .noIntersection
            }
            
            let dSquared = inter.distanceSquared(to: rayInfo.ray.start)
            guard dSquared < rayInfo.rayMagnitudeSquared else {
                return .noIntersection
            }
            
            var normal: RVector3D = plane.normal
            if normal.dot(rayInfo.ray.direction) > 0 {
                normal = -normal
            }
            
            return .singlePoint(PointNormal(point: inter, normal: normal))
        }
    }
    
    func doRayCast(partialResult: Scene.PartialRayResult) -> Scene.PartialRayResult {
        if let aabb = self.bounds, let rayAABB = partialResult.rayAABB {
            if !aabb.intersects(rayAABB) {
                return partialResult
            }
        }
        
        guard let hit = doRayCast(ray: partialResult.ray,
                                  rayMagnitudeSquared: partialResult.rayMagnitudeSquared,
                                  ignoring: partialResult.ignoring) else {
            return partialResult
        }
        
        return partialResult.withHit(hit)
    }
    
    /// Performs raycasting for a single ray on this SceneGeometry.
    ///
    /// Returns `nil` if this geometry was not intersected according to the ray
    /// and `ignore` rule specified.
    func doRayCast(ray: RRay3D, ignoring: RayIgnore) -> RayHit? {
        return doRayCast(ray: ray, rayMagnitudeSquared: .infinity, ignoring: ignoring)
    }
    
    /// Performs raycasting for a single ray on this SceneGeometry.
    ///
    /// Returns `nil` if this geometry was not intersected according to the ray
    /// and `ignore` rule specified.
    func doRayCast(ray: RRay3D, rayMagnitudeSquared: Double, ignoring: RayIgnore) -> RayHit? {
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return nil
        }
        
        let info = RayInfo(ray: ray, rayMagnitudeSquared: rayMagnitudeSquared)
        
        let result = _doRayCast(info)
        
        return RayHit(findingPointOfInterestOf: ignoring,
                      intersection: result,
                      sceneGeometry: self)
    }
    
    /// Returns the result of the distance function applied using a given point
    /// vector.
    ///
    /// Returns `.infinity` in case this geometry is ignored by `ignoring`.
    func signedDistanceFunction(_ point: RVector3D, minDistance: Double, ignoring: RayIgnore = .none) -> Double {
        guard !ignoring.shouldIgnoreFully(id: id) else {
            return .infinity
        }
        
        let result = _signedDistanceFunction(point, minDistance)
        
        // Handle ray ignore
        switch ignoring {
        case let .exit(geoId, dist) where result < 0 && geoId == id && abs(result) < dist:
            return .infinity
            
        case let .entrance(geoId, dist) where result > 0 && geoId == id && abs(result) < dist:
            return .infinity
            
        default:
            break
        }
        
        return result
    }
    
    private struct RayInfo {
        var ray: RRay3D
        var rayMagnitudeSquared: Double
    }
}
