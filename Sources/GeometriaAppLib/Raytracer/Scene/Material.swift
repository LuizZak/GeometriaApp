import SwiftBlend2D

struct Material {
    var color: BLRgba32
    
    /// Values > 0 increase the reflectivity of the geometry.
    var reflectivity: Double = 0.0
    
    /// Values > 0 increase the transparency of the geometry.
    var transparency: Double = 0.0
    
    /// Refractive index. Value of == 1.0 matches world's refractive index, i.e.
    /// it causes no light refraction.
    var refractiveIndex: Double = 1.0
}
