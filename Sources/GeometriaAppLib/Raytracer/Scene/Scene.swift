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
        
        // AABB - top
        let aabbTop: Geometria.AABB<Vector3D> =
            .init(minimum: .init(x: -70, y: 120, z: 60),
                  maximum: .init(x: 10, y: 140, z: 112))
        
        // AABB - back
        let aabbBack: Geometria.AABB<Vector3D> =
            .init(minimum: .init(x: -50, y: 200, z: 10),
                  maximum: .init(x: 0, y: 210, z: 50))
        
        // Sphere
        let sphere: NSphere<Vector3D> = .init(center: .init(x: 0, y: 150, z: 45), radius: 30)
        
        // Second sphere
        let sphere2: NSphere<Vector3D> = .init(center: .init(x: 70, y: 150, z: 45), radius: 30)
        
        // Floor plane
        let floorPlane: Plane = Plane(point: .zero, normal: .unitZ)
        
        // Disk
        let disk: Disk3<Vector3D> = Disk3(center: .init(x: -10, y: 110, z: 20),
                                          normal: .unitY,
                                          radius: 12)
        
        // Ellipse
        let ellipse: Ellipse3<Vector3D> = .init(center: .init(x: -50, y: 90, z: 20),
                                                radius: .init(x: 20, y: 15, z: 10))
        
        addPlane(floorPlane)
        addAABB(aabbTop)
        addAABB(aabbBack)
        addBumpySphere(sphere2)
        addDisk(disk)
        addShinyEllipse3(ellipse)
        addShinySphere(sphere, transparency: 0.5, refractiveIndex: 1.3)
    }
    
    func addAABB(_ object: Geometria.AABB<Vector3D>) {
        let material = Material(color: .gray)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addSphere(_ object: Geometria.NSphere<Vector3D>) {
        let material = Material(color: .gray)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addBumpySphere(_ object: Geometria.NSphere<Vector3D>) {
        let material = Material(color: .gray, reflectivity: 0.4)
        let geom = SceneGeometry(bumpySphere: object, material: material)
        geometries.append(geom)
    }
    
    func addShinySphere(_ object: Geometria.NSphere<Vector3D>,
                        transparency: Double = 0.0,
                        refractiveIndex: Double = 1.0) {
        
        let material = Material(color: .gray,
                                reflectivity: 0.6,
                                transparency: transparency,
                                refractiveIndex: refractiveIndex)
        
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addShinyEllipse3(_ object: Geometria.Ellipse3<Vector3D>, transparency: Double = 0.0) {
        let material = Material(color: .gray, reflectivity: 0.5, transparency: transparency)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addDisk(_ object: Geometria.Disk3<Vector3D>) {
        let material = Material(color: .white)
        let geom = SceneGeometry(plane: object, material: material)
        geometries.append(geom)
    }
    
    func addPlane(_ object: Geometria.PointNormalPlane<Vector3D>) {
        let material = Material(color: .gray)
        let geom = SceneGeometry(plane: object, material: material)
        geometries.append(geom)
    }
    
    @inlinable
    func intersect(ray: Ray, ignoring: RayIgnore = .none) -> RayHit? {
        var result =
            PartialRayResult(ray: ray,
                             rayMagnitudeSquared: .infinity,
                             lastHit: nil,
                             ignoring: ignoring)
        
        for geo in geometries where !ignoring.shouldIgnoreFully(sceneGeometry: geo) {
            result = geo.doRayCast(partialResult: result)
        }
        
        return result.lastHit
    }
    
    /// Returns a list of all geometry that intersects a given ray.
    @inlinable
    func intersectAll(ray: Ray, ignoring: RayIgnore = .none) -> [RayHit] {
        var hits: [RayHit] = []
        
        for geo in geometries where !ignoring.shouldIgnoreFully(sceneGeometry: geo) {
            let result =
                PartialRayResult(
                    ray: ray,
                    rayMagnitudeSquared: .infinity,
                    lastHit: nil,
                    ignoring: ignoring
                )
            
            if let hit = geo.doRayCast(partialResult: result).lastHit?.assignPointOfInterest(from: ignoring) {
                hits.append(hit)
            }
        }
        
        return hits
    }
    
    struct PartialRayResult {
        var ray: Ray
        var rayAABB: AABB3D?
        /// Current magnitude of ray's hit point. Is `.infinity` for newly casted
        /// rays that did not intersect geometry yet.
        var rayMagnitudeSquared: Double
        var lastHit: RayHit?
        var ignoring: RayIgnore
        
        func withHit(magnitudeSquared: Double,
                     point: Vector3D,
                     normal: Vector3D,
                     intersection: ConvexLineIntersection<Vector3D>,
                     sceneGeometry: SceneGeometry) -> PartialRayResult {
            
            let hit = RayHit(pointOfInterest: .init(point: point, normal: normal),
                             intersection: intersection,
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
