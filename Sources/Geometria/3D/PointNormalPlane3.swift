/// Represents a 3D plane as a pair of double-precision floating-point vectors
/// describing a point on the plane and the plane's normal.
public typealias PointNormalPlane3D = PointNormalPlane3<Vector3D>

/// Typealias for `Plane<V>`, where `V` is constrained to ``Vector3FloatingPoint``.
public typealias PointNormalPlane3<V: Vector3FloatingPoint> = PointNormalPlane<V>
