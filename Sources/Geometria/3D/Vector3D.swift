#if canImport(simd)

import simd

/// Represents a 3D point with three double-precision floating-point components
public typealias Vector3D = SIMD3<Double>

#else

/// Represents a 3D point with three double-precision floating-point components
public typealias Vector3D = Vector3//<Double>

#endif
