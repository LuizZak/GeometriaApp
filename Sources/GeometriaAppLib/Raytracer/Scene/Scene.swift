import SwiftBlend2D
import Geometria

class Scene {
    // Sky color for pixels that don't intersect with geometry
    var skyColor: BLRgba32 = .cornflowerBlue
    
    var geometries: [SceneGeometry] = []
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: Vector3D = Vector3D(x: -20, y: 40, z: -30)
    
    init() {
        createScene()
    }
    
    func createScene() {
        
        // AABB
        let aabb: Geometria.AABB<Vector3D> = .init(minimum: .init(x: -70, y: 90, z: 60),
                                                   maximum: .init(x: 10, y: 100, z: 95))
        
        // Sphere
        let sphere: NSphere<Vector3D> = .init(center: .init(x: 0, y: 150, z: 45), radius: 30)
        
        // Second
        let sphere2: NSphere<Vector3D> = .init(center: .init(x: 70, y: 150, z: 45), radius: 30)
        
        // Floor plane
        let floorPlane: Plane = Plane(point: .zero, normal: .unitZ)
        
        // Disk
        let disk: Disk3<Vector3D> = Disk3(center: .init(x: -10, y: 110, z: 20),
                                          normal: .unitY,
                                          radius: 12)
        
        addAABB(aabb)
        addShinySphere(sphere)
        addBumpySphere(sphere2)
        addDisk(disk)
        addPlane(floorPlane)
    }
    
    func addAABB(_ object: Geometria.AABB<Vector3D>) {
        let material = SceneGeometry.Material(color: .gray)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addSphere(_ object: Geometria.NSphere<Vector3D>) {
        let material = SceneGeometry.Material(color: .gray)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addBumpySphere(_ object: Geometria.NSphere<Vector3D>) {
        let material = SceneGeometry.Material(color: .gray, reflectivity: 0.4)
        let geom = SceneGeometry(bumpySphere: object, material: material)
        geometries.append(geom)
    }
    
    func addShinySphere(_ object: Geometria.NSphere<Vector3D>) {
        let material = SceneGeometry.Material(color: .gray, reflectivity: 0.4)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addDisk(_ object: Geometria.Disk3<Vector3D>) {
        let material = SceneGeometry.Material(color: .white)
        let geom = SceneGeometry(plane: object, material: material)
        geometries.append(geom)
    }
    
    func addPlane(_ object: Geometria.PointNormalPlane<Vector3D>) {
        let material = SceneGeometry.Material(color: .gray)
        let geom = SceneGeometry(plane: object, material: material)
        geometries.append(geom)
    }
    
    @inlinable
    func intersect(ray: Ray, ignoring: SceneGeometry? = nil) -> RayHit? {
        var result =
            PartialRayResult(ray: ray,
                             rayMagnitudeSquared: .infinity,
                             lastHit: nil,
                             ignoring: ignoring)
        
        for geo in geometries {
            result = geo.doRayCast(partialResult: result)
        }
        
        return result.lastHit
    }
    
    struct PartialRayResult {
        var ray: Ray
        var rayAABB: AABB3D?
        var rayMagnitudeSquared: Double
        var lastHit: RayHit?
        var ignoring: SceneGeometry?
        
        func withHit(magnitudeSquared: Double,
                     point: Vector3D,
                     normal: Vector3D,
                     sceneGeometry: SceneGeometry) -> PartialRayResult {
            
            let hit = RayHit(point: point,
                             normal: normal,
                             sceneGeometry: sceneGeometry)
            
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
