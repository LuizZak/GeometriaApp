#if canImport(simd)

import simd

/// Represents a 2D point with two double-precision floating-point components
public typealias Vector2D = SIMD2<Double>

#else

/// Represents a 2D point with two double-precision floating-point components
public typealias Vector2D = Vector2

#endif
