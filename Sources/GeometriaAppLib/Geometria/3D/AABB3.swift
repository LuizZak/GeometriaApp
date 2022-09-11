/// Represents a 3D axis-aligned bounding box with two double-precision
/// floating-point vectors that describe the minimal and maximal coordinates
/// of the box's opposite corners.
public typealias AABB3D = AABB3<Vector3D>

/// Typealias for `AABB<V>`, where `V` is constrained to ``Vector3Type``.
public typealias AABB3<V: Vector3Type> = AABB<V>

extension AABB3: Convex3Type where Vector: Vector3FloatingPoint {
    
    /// Rotates this AABB around the origin using a given rotation matrix.
    @inlinable
    public func rotated(by matrix: RotationMatrix3) -> Self {
        let points = vertices.transformed(by: matrix)
        
        return Self(points: points)
    }
    
    /// Rotates this AABB around a center point using a given rotation matrix.
    @inlinable
    public func rotated(by matrix: RotationMatrix3, around center: Vector) -> Self {
        let points = vertices.map {
            matrix.transformPoint($0 - center) + center
        }
        
        return Self(points: points)
    }
}
