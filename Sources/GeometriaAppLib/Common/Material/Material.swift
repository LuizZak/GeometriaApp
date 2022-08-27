import SwiftBlend2D

enum Material: Equatable {
    static let `default`: Self = .diffuse(.default)

    case diffuse(DiffuseMaterial)
    case checkerboard(size: Double, color1: BLRgba32, color2: BLRgba32)
    case target(center: RVector3D, stripeFrequency: Double, color1: BLRgba32, color2: BLRgba32)
    
    var transparency: Double {
        switch self {
        case .diffuse(let diffuse):
            return diffuse.transparency
            
        case .checkerboard, .target:
            return 0.0
        }
    }

    static func solid(_ color: BLRgba32) -> Material {
        .diffuse(.default.withColor(color))
    }
}

@_transparent
func mix(_ lhs: Material, _ rhs: Material, factor: Double) -> Material {
    // TODO: Implement proper material mixing
    factor >= 0.5 ? rhs : lhs
}

@_transparent
func mix(_ lhs: Material?, _ rhs: Material?, factor: Double) -> Material? {
    guard let lhs = lhs else {
        return rhs
    }
    guard let rhs = rhs else {
        return lhs
    }

    return mix(lhs, rhs, factor: factor)
}
