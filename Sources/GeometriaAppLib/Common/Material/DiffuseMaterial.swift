import SwiftBlend2D

public struct DiffuseMaterial: Equatable, CustomStringConvertible {
    public static let `default`: DiffuseMaterial = .init()
    
    // TODO: Attempt using different type for defining color in raytracer to
    // TODO: see if it improves performance over BLRgba32.
    public var color: BLRgba32 = .gray
    
    /// Frequency of Perlin noise used in surface bumps.
    public var bumpNoiseFrequency: Double = 1.0
    
    /// Magnitude of bump for offsetting normals.
    public var bumpMagnitude: Double = 0.0
    
    /// Values > 0 increase the reflectivity of the geometry.
    public var reflectivity: Double = 0.0
    
    /// Values > 0 increase the transparency of the geometry.
    public var transparency: Double = 0.0
    
    /// Refractive index. Value of == 1.0 matches world's refractive index, i.e.
    /// it causes no light refraction.
    public var refractiveIndex: Double = 1.0
    
    /// Returns `true` if this material has a refractive index different from
    /// the world's, i.e. `refractiveIndex != 1.0`.
    public var hasRefraction: Bool {
        return refractiveIndex != 1.0
    }
    
    public var description: String {
        """
        \(type(of: self))(color: \(color), bumpNoiseFrequency: \(bumpNoiseFrequency), \
        bumpMagnitude: \(bumpMagnitude), reflectivity: \(reflectivity), \
        transparency: \(transparency), refractiveIndex: \(refractiveIndex))
        """
    }

    public init(
        color: BLRgba32 = .gray,
        bumpNoiseFrequency: Double = 1.0,
        bumpMagnitude: Double = 0.0,
        reflectivity: Double = 0.0,
        transparency: Double = 0.0,
        refractiveIndex: Double = 1.0
    ) {

        self.color = color
        self.bumpNoiseFrequency = bumpNoiseFrequency
        self.bumpMagnitude = bumpMagnitude
        self.reflectivity = reflectivity
        self.transparency = transparency
        self.refractiveIndex = refractiveIndex
    }

    public func withColor(_ color: BLRgba32) -> Self {
        return .init(
            color: color, 
            bumpNoiseFrequency: bumpNoiseFrequency, 
            bumpMagnitude: bumpMagnitude, 
            reflectivity: reflectivity, 
            transparency: transparency, 
            refractiveIndex: refractiveIndex
        )
    }
}

@_transparent
public func mix(_ m0: DiffuseMaterial, _ m1: DiffuseMaterial, factor: Double) -> DiffuseMaterial {
    let color = mix(m0.color, m1.color, factor: factor)
    let bumpNoiseFrequency = mix(m0.bumpNoiseFrequency, m1.bumpNoiseFrequency, factor: factor)
    let bumpMagnitude = mix(m0.bumpMagnitude, m1.bumpMagnitude, factor: factor)
    let reflectivity = mix(m0.reflectivity, m1.reflectivity, factor: factor)
    let transparency = mix(m0.transparency, m1.transparency, factor: factor)
    let refractiveIndex = mix(m0.refractiveIndex, m1.refractiveIndex, factor: factor)

    return .init(
        color: color, 
        bumpNoiseFrequency: bumpNoiseFrequency, 
        bumpMagnitude: bumpMagnitude, 
        reflectivity: reflectivity, 
        transparency: transparency, 
        refractiveIndex: refractiveIndex
    )
}

@_transparent
public func mix(_ m0: DiffuseMaterial?, _ m1: DiffuseMaterial?, factor: Double) -> DiffuseMaterial? {
    guard let m0 = m0 else {
        return m1
    }
    guard let m1 = m1 else {
        return m0
    }

    return mix(m0, m1, factor: factor)
}
