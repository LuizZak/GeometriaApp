import SwiftBlend2D

protocol RaytracingSceneType: SceneType {
    // Sky color for pixels that don't intersect with geometry
    var skyColor: BLRgba32 { get }
    
    /// Direction an infinitely far away point light is pointed at the scene
    var sunDirection: RVector3D { get }
    
    func intersect(ray: RRay3D, ignoring: RayIgnore) -> RayHit?
    
    /// Returns a list of all geometry that intersects a given ray.
    func intersectAll(ray: RRay3D, ignoring: RayIgnore) -> [RayHit]
}
