import SwiftBlend2D

protocol RaytracingSceneType {
    // Sky color for pixels that don't intersect with geometry
    var skyColor: BLRgba32 { get }
    
    /// Direction an infinitely far away point light is pointed at the scene
    var sunDirection: RVector3D { get }
    
    mutating func attributeIds(_ idFactory: inout RaytracingElementIdFactory)
}
