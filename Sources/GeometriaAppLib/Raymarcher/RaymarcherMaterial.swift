import SwiftBlend2D

enum RaymarcherMaterial {
    static let `default`: Self = .solid(.gray)

    case solid(BLRgba32)
    case checkerboard(size: Double, color1: BLRgba32, color2: BLRgba32)
    case target(center: RVector3D, stripeFrequency: Double, color1: BLRgba32, color2: BLRgba32)
}

@_transparent
func mix(_ lhs: RaymarcherMaterial, _ rhs: RaymarcherMaterial, factor: Double) -> RaymarcherMaterial {
    // TODO: Implement proper material mixing
    factor >= 0.5 ? rhs : lhs
}

@_transparent
func mix(_ lhs: RaymarcherMaterial?, _ rhs: RaymarcherMaterial?, factor: Double) -> RaymarcherMaterial? {
    guard let lhs = lhs else {
        return rhs
    }
    guard let rhs = rhs else {
        return lhs
    }

    return mix(lhs, rhs, factor: factor)
}
