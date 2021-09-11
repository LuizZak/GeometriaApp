import SwiftBlend2D

final class Scene {
    // Sky color for pixels that don't intersect with geometry
    var skyColor: BLRgba32 = .cornflowerBlue
    
    var geometries: [SceneGeometry] = []
    
    /// Direction an infinitely far away point light is pointed at the scene
    @UnitVector var sunDirection: RVector3D = RVector3D(x: -20, y: 40, z: -30)
    
    func addGeometry(_ geometry: SceneGeometry) {
        geometries.append(geometry)
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
