/// Represents a 2D plane as a pair of double-precision floating-point vectors
/// describing a point on the plane and the plane's normal.
public typealias PointNormalPlane2D = PointNormalPlane2<Vector2D>

/// Typealias for `PointNormalPlane<V>`, where `V` is constrained to
/// ``Vector2FloatingPoint``.
public typealias PointNormalPlane2<V: Vector2FloatingPoint> = PointNormalPlane<V>
