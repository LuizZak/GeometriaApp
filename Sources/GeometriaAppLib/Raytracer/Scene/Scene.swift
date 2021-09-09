import SwiftBlend2D

final class Scene {
    // Sky color for pixels that don't intersect with geometry
    var skyColor: BLRgba32 = .cornflowerBlue
    
    var geometries: [SceneGeometry] = []
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)
    
    init() {
        createScene()
    }
    
    func createScene() {
        
        // AABB - top
        let aabbTop: RAABB3D =
            .init(minimum: .init(x: -70, y: 120, z: 60),
                  maximum: .init(x: 10, y: 140, z: 112))
        
        // AABB - back
        let aabbBack: RAABB3D =
            .init(minimum: .init(x: -50, y: 200, z: 10),
                  maximum: .init(x: 0, y: 210, z: 50))
        
        // Sphere
        let sphere: RSphere3D = .init(center: .init(x: 0, y: 150, z: 45), radius: 30)
        
        // Second sphere
        let sphere2: RSphere3D = .init(center: .init(x: 70, y: 150, z: 45), radius: 30)
        
        // Ellipse
        let ellipse: REllipse3D = .init(center: .init(x: -50, y: 90, z: 20),
                                                 radius: .init(x: 20, y: 15, z: 10))
        
        // Cylinder
        let cylinder: RCylinder3D = .init(start: .init(x: 60, y: 150, z: 0),
                                          end: .init(x: 60, y: 150, z: 100),
                                          radius: 20)
        
        // Disk
        let disk: RDisk3D = RDisk3D(center: .init(x: -10, y: 110, z: 20),
                                             normal: .unitY,
                                             radius: 12)
        
        // Floor plane
        let floorPlane: RPlane3D = RPlane3D(point: .zero, normal: .unitZ)
        
        addPlane(floorPlane)
        addDisk(disk)
        addAABB(aabbTop)
        addAABB(aabbBack, color: .indianRed)
        addCylinder(cylinder, transparency: 1.0, refractivity: 1.3)
        addBumpySphere(sphere2)
        addShinyEllipse3(ellipse)
        addShinySphere(sphere, transparency: 1.0, refractiveIndex: 1.3)
    }
    
    func addAABB(_ object: RAABB3D, color: BLRgba32 = .gray) {
        let material = Material(color: color)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addSphere(_ object: RSphere3D) {
        let material = Material(color: .gray)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addBumpySphere(_ object: RSphere3D) {
        let material = Material(color: .gray, reflectivity: 0.4)
        let geom = SceneGeometry(bumpySphere: object, material: material)
        geometries.append(geom)
    }
    
    func addShinySphere(_ object: RSphere3D,
                        transparency: Double = 0.0,
                        refractiveIndex: Double = 1.0) {
        
        let material = Material(color: .gray,
                                reflectivity: 0.6,
                                transparency: transparency,
                                refractiveIndex: refractiveIndex)
        
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addShinyEllipse3(_ object: REllipse3D, transparency: Double = 0.0) {
        let material = Material(color: .gray, reflectivity: 0.5, transparency: transparency)
        let geom = SceneGeometry(convex: object, material: material)
        geometries.append(geom)
    }
    
    func addCylinder(_ object: RCylinder3D,
                     reflectivity: Double = 0.0,
                     transparency: Double = 0.0,
                     refractivity: Double = 1.0) {
        
        let material = Material(color: .gray,
                                reflectivity: reflectivity,
                                transparency: transparency,
                                refractiveIndex: refractivity)
        
        let geom = SceneGeometry(convex3: object, material: material)
        geometries.append(geom)
    }
    
    func addDisk(_ object: RDisk3D) {
        let material = Material(color: .white)
        let geom = SceneGeometry(plane: object, material: material)
        geometries.append(geom)
    }
    
    func addPlane(_ object: RPlane3D) {
        let material = Material(color: .gray)
        let geom = SceneGeometry(plane: object, material: material)
        geometries.append(geom)
    }
    
    @inlinable
    func intersect(ray: RRay3D, ignoring: RayIgnore = .none) -> RayHit? {
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
    func intersectAll(ray: RRay3D, ignoring: RayIgnore = .none) -> [RayHit] {
        var hits: [RayHit] = []
        
        for geo in geometries where !ignoring.shouldIgnoreFully(sceneGeometry: geo) {
            if let hit = geo.doRayCast(ray: ray, ignoring: ignoring) {
                hits.append(hit)
            }
        }
        
        return hits
    }
    
    struct PartialRayResult {
        var ray: RRay3D
        var rayAABB: RAABB3D?
        /// Current magnitude of ray's hit point. Is `.infinity` for newly casted
        /// rays that did not intersect geometry yet.
        var rayMagnitudeSquared: Double
        var lastHit: RayHit?
        var ignoring: RayIgnore
        
        func withHit(_ rayHit: RayHit) -> PartialRayResult {
            let point = rayHit.point
            let magnitudeSquared = point.distanceSquared(to: ray.start)
            
            let newAABB = RAABB3D(minimum: RVector3D.pointwiseMin(ray.start, point),
                                  maximum: RVector3D.pointwiseMax(ray.start, point))
            
            return PartialRayResult(ray: ray,
                                    rayAABB: newAABB,
                                    rayMagnitudeSquared: magnitudeSquared,
                                    lastHit: rayHit,
                                    ignoring: ignoring)
        }
        
        func withHit(magnitudeSquared: Double,
                     point: RVector3D,
                     normal: RVector3D,
                     intersection: ConvexLineIntersection<RVector3D>,
                     sceneGeometry: SceneGeometry) -> PartialRayResult {
            
            let hit = RayHit(pointOfInterest: .init(point: point, normal: normal),
                             intersection: intersection,
                             sceneGeometry: sceneGeometry)
            
            return withHit(hit)
        }
    }
}
