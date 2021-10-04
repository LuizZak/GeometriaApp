import SwiftBlend2D

enum RaytracingMaterial {
    static let `default`: Self = .diffuse(.default)
    
    case diffuse(Material)
    case checkerboard(size: Double, color1: BLRgba32, color2: BLRgba32)
    case target(center: RVector3D, stripeFrequency: Double, color1: BLRgba32, color2: BLRgba32)
}
