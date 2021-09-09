import SwiftBlend2D

struct Material: CustomStringConvertible {
    // TODO: Attempt using different type for defining color in raytracer to
    // TODO: see if it improves performance over BLRgba32.
    var color: BLRgba32
    
    /// Values > 0 increase the reflectivity of the geometry.
    var reflectivity: Double = 0.0
    
    /// Values > 0 increase the transparency of the geometry.
    var transparency: Double = 0.0
    
    /// Refractive index. Value of == 1.0 matches world's refractive index, i.e.
    /// it causes no light refraction.
    var refractiveIndex: Double = 1.0
    
    /// Returns `true` if this material has a refractive index different from
    /// the world's, i.e. `refractiveIndex != 1.0`.
    var hasRefraction: Bool {
        return refractiveIndex != 1.0
    }
    
    var description: String {
        "\(type(of: self))(color: \(color), reflectivity: \(reflectivity), transparency: \(transparency), refractiveIndex: \(refractiveIndex))"
    }
}
