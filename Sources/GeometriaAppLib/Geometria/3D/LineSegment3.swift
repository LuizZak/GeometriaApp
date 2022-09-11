/// Represents a 3D line as a pair of double-precision floating-point start and
/// end vectors.
public typealias LineSegment3D = LineSegment3<Vector3D>

/// Typealias for `LineSegment<V>`, where `V` is constrained to ``Vector3Type``.
public typealias LineSegment3<V: Vector3Type> = LineSegment<V>

extension LineSegment3: Line3Type {
    public typealias SubLine2 = LineSegment2<Vector.SubVector2>
    
    @_transparent
    public init(x1: Scalar, y1: Scalar, z1: Scalar, x2: Scalar, y2: Scalar, z2: Scalar) {
        start = Vector(x: x1, y: y1, z: z1)
        end = Vector(x: x2, y: y2, z: z2)
    }
    
    /// Creates a 2D line of the same underlying type as this line.
    @_transparent
    public static func make2DLine(_ a: Vector.SubVector2, _ b: Vector.SubVector2) -> SubLine2 {
        SubLine2(start: a, end: b)
    }
}

extension LineSegment3: Line3FloatingPoint where Vector: Vector3FloatingPoint {
    
    /// Rotates this line segment around the origin using a given rotation
    /// matrix.
    @inlinable
    public func rotated(by matrix: RotationMatrix3) -> Self {
        let aT = matrix.transformPoint(start)
        let bT = matrix.transformPoint(end)
        
        return Self(start: aT, end: bT)
    }
    
    /// Rotates this line segment around a center point using a given rotation
    /// matrix.
    @inlinable
    public func rotated(by matrix: RotationMatrix3, around center: Vector) -> Self {
        let aT = matrix.transformPoint(start - center) + center
        let bT = matrix.transformPoint(end - center) + center
        
        return Self(start: aT, end: bT)
    }
}
