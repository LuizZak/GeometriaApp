import Geometria

class SceneGeometry {
    private var _doRayCast: (_ partialResult: Scene.PartialRayResult) -> Scene.PartialRayResult
    var bounds: AABB3<Vector3D>?
    
    init<C: ConvexType & BoundableType & Equatable>(convex: C) where C.Vector == Vector3D {
        self.bounds = convex.bounds
        
        _doRayCast = { result in
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
    }
    
    init<P: LineIntersectivePlaneType & Equatable>(plane: P) where P.Vector == Vector3D {
        _doRayCast = { result in
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
    }
    
    func doRayCast(partialResult: Scene.PartialRayResult) -> Scene.PartialRayResult {
        if let aabb = self.bounds, let rayAABB = partialResult.rayAABB {
            if !aabb.intersects(rayAABB) {
                return partialResult
            }
        }
        
        return _doRayCast(partialResult)
    }
}
