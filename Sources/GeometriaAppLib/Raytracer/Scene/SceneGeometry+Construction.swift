import SwiftBlend2D

extension SceneGeometry {
    mutating func withColor(_ color: BLRgba32) {
        material.color = color
    }
    
    mutating func withTransparency(_ transparency: Double) {
        material.transparency = transparency
    }
    
    mutating func withReflectivity(_ reflectivity: Double) {
        material.reflectivity = reflectivity
    }
    
    mutating func withRefractiveIndex(_ refractiveIndex: Double) {
        material.refractiveIndex = refractiveIndex
    }
}
