import SwiftBlend2D

struct Material {
    var color: BLRgba32
    
    /// Values > 0 increase the reflectivity of the geometry.
    var reflectivity: Double = 0.0
    
    /// Values > 0 increase the transparency of the geometry.
    var transparency: Double = 0.0
}
