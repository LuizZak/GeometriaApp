import Geometria

struct Scene {
    // AABB
    var aabb: Geometria.AABB<Vector3D> = .init(minimum: .init(x: -20, y: 90, z: 60),
                                               maximum: .init(x: 60, y: 100, z: 95))
    
    // Sphere
    var sphere: NSphere<Vector3D> = .init(center: .init(x: 0, y: 150, z: 45), radius: 30)
    
    // Floor plane
    var floorPlane: Plane = Plane(point: .zero, normal: .unitZ)
    
    // Disk
    var disk: Disk3<Vector3D> = Disk3(center: .init(x: -10, y: 110, z: 20),
                                      normal: .init(x: 0, y: 1, z: 0),
                                      radius: 12)
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: Vector3D = Vector3D(x: -20, y: 40, z: -30)
    
    @inlinable
    func intersect(ray: Ray, ignoring: GeometricType? = nil) -> RayHit? {
        var result =
            PartialRayResult(ray: ray,
                             rayMagnitudeSquared: .infinity,
                             lastHit: nil,
                             ignoring: ignoring)
        
        result = doPlane(plane: floorPlane, result: result)
        result = doPlane(plane: disk, result: result)
        result = doConvex(convex: aabb, result: result)
        result = doConvex(convex: sphere, result: result)
        
        return result.lastHit
    }
    
    @inlinable
    func doBoundConvex<C: ConvexType & BoundableType & Equatable>(convex: C, result: PartialRayResult) -> PartialRayResult where C.Vector == Vector3D {
        
        if let aabb = result.rayAABB {
            if !convex.bounds.intersects(aabb) {
                return result
            }
        }
        
        return doConvex(convex: convex, result: result)
    }
    
    @inlinable
    func doConvex<C: ConvexType & Equatable>(convex: C, result: PartialRayResult) -> PartialRayResult where C.Vector == Vector3D {
        if result.ignoring as? C == convex {
            return result
        }
        
        switch convex.intersection(with: result.ray) {
        case .enter(let pt),
             .enterExit(let pt, _),
             .singlePoint(let pt):
            
            let distSq = pt.point.distanceSquared(to: result.ray.start)
            if distSq > result.rayMagnitudeSquared {
                return result
            }
            
            return result.withHit(magnitudeSquared: distSq,
                                  point: pt.point,
                                  normal: pt.normal,
                                  geometry: convex)
        default:
            return result
        }
    }
    
    @inlinable
    func doPlane<P: LineIntersectivePlaneType & Equatable>(plane: P, result: PartialRayResult) -> PartialRayResult where P.Vector == Vector3D {
        
        guard result.ignoring as? P != plane else {
            return result
        }
        guard let inter = plane.intersection(with: result.ray) else {
            return result
        }
        
        let dSquared = inter.distanceSquared(to: result.ray.start)
        guard dSquared < result.rayMagnitudeSquared else {
            return result
        }
        
        var normal: Vector3D = plane.normal
        if normal.dot(result.ray.direction) > 0 {
            normal = -normal
        }
        
        return result.withHit(magnitudeSquared: dSquared,
                              point: inter,
                              normal: normal,
                              geometry: plane)
    }
    
    struct PartialRayResult {
        var ray: Ray
        var rayAABB: AABB3D?
        var rayMagnitudeSquared: Double
        var lastHit: RayHit?
        var ignoring: GeometricType?
        
        func withHit(magnitudeSquared: Double,
                     point: Vector3D,
                     normal: Vector3D,
                     geometry: GeometricType) -> PartialRayResult {
            
            let hit = RayHit(point: point, normal: normal, geometry: geometry)
            let newAABB = AABB3D(minimum: Vector3D.pointwiseMin(ray.start, point),
                                 maximum: Vector3D.pointwiseMax(ray.start, point))
            
            return PartialRayResult(ray: ray,
                                    rayAABB: newAABB,
                                    rayMagnitudeSquared: magnitudeSquared,
                                    lastHit: hit,
                                    ignoring: ignoring)
        }
    }
}
