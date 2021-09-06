import Geometria
import blend2d

class SceneGeometry {
    private var _doRayCast: (_ partialResult: Scene.PartialRayResult) -> Scene.PartialRayResult
    var bounds: AABB3<Vector3D>?
    var material: Material
    
    init<C: ConvexType & BoundableType & Equatable>(convex: C, material: Material) where C.Vector == Vector3D {
        self.bounds = convex.bounds
        self.material = material
        
        weak var sSelf: SceneGeometry?
        
        _doRayCast = { result in
            guard let self = sSelf else {
                return result
            }
            
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
                                      geometry: convex,
                                      sceneGeometry: self)
            default:
                return result
            }
        }
        
        sSelf = self
    }
    
    init(bumpySphere: Sphere3<Vector3D>, material: Material) {
        self.bounds = bumpySphere.bounds
        self.material = material
        
        weak var sSelf: SceneGeometry?
        
        _doRayCast = { result in
            guard let self = sSelf else {
                return result
            }
            
            if result.ignoring as? Sphere3<Vector3D> == bumpySphere {
                return result
            }
            
            switch bumpySphere.intersection(with: result.ray) {
            case .enter(let pt),
                 .enterExit(let pt, _),
                 .singlePoint(let pt):
                
                let distSq = pt.point.distanceSquared(to: result.ray.start)
                if distSq > result.rayMagnitudeSquared {
                    return result
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
                
                return result.withHit(magnitudeSquared: distSq,
                                      point: pt.point,
                                      normal: normal,
                                      geometry: bumpySphere,
                                      sceneGeometry: self)
            default:
                return result
            }
        }
        
        sSelf = self
    }
    
    init<P: LineIntersectivePlaneType & Equatable>(plane: P, material: Material) where P.Vector == Vector3D {
        self.material = material
        
        weak var sSelf: SceneGeometry?
        
        _doRayCast = { result in
            guard let self = sSelf else {
                return result
            }
            
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
                                  geometry: plane,
                                  sceneGeometry: self)
        }
        
        sSelf = self
    }
    
    func doRayCast(partialResult: Scene.PartialRayResult) -> Scene.PartialRayResult {
        if let aabb = self.bounds, let rayAABB = partialResult.rayAABB {
            if !aabb.intersects(rayAABB) {
                return partialResult
            }
        }
        
        return _doRayCast(partialResult)
    }
    
    struct Material {
        var color: BLRgba32
        var reflectivity: Double = 0.0
    }
}
