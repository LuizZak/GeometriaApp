#if canImport(simd)

import simd

/// Represents a 4D point with three double-precision floating-point components
public typealias Vector4D = SIMD4<Double>

#else

/// Represents a 4D point with three double-precision floating-point components
public typealias Vector4D = Vector4//<Double>

#endif
