/// Protocol for 4D vector types where the components are floating-point numbers
public protocol Vector4FloatingPoint: Vector4Additive, VectorMultiplicative & VectorFloatingPoint where SubVector3: Vector3FloatingPoint {
    
}
