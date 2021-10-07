/// Represents a 3D axis-aligned bounding box with two double-precision
/// floating-point vectors that describe the minimal and maximal coordinates
/// of the box's opposite corners.
public typealias AABB3D = AABB3<Vector3D>

/// Typealias for `AABB<V>`, where `V` is constrained to ``Vector3Type``.
public typealias AABB3<V: Vector3Type> = AABB<V>

extension AABB3: Convex3Type where Vector: Vector3FloatingPoint {
    
}
