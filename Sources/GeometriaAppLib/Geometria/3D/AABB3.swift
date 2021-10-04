/// Represents a 3D axis-aligned bounding box with two double-precision
/// floating-point vectors that describe the minimal and maximal coordinates
/// of the box's opposite corners.
public typealias AABB3D = AABB3<Vector3D>

/// Typealias for `AABB<V>`, where `V` is constrained to ``Vector3Type``.
public typealias AABB3<V: Vector3Type> = AABB<V>

extension AABB3: Convex3Type where Vector: Vector3FloatingPoint {
    /// Returns `true` if this AABB's area intersects the given line type.
    @inlinable
    public func intersects<Line: Line3FloatingPoint>(line: Line) -> Bool where Line.Vector == Vector {
        // Derived from C# implementation at: https://stackoverflow.com/a/3115514
        let lineSlope = line.lineSlope
        
        let lineToMin = minimum - line.a
        let lineToMax = maximum - line.a
        var tNear = -Scalar.infinity
        var tFar = Scalar.infinity
        
        let t1 = lineToMin / lineSlope
        let t2 = lineToMax / lineSlope
        let tMin = min(t1, t2)
        let tMax = max(t1, t2)
        
        if lineSlope.x != 0 {
            tNear = max(tNear, tMin.x)
            tFar = min(tFar, tMax.x)
        }
        if lineSlope.y != 0 {
            tNear = max(tNear, tMin.y)
            tFar = min(tFar, tMax.y)
        }
        if lineSlope.z != 0 {
            tNear = max(tNear, tMin.z)
            tFar = min(tFar, tMax.z)
        }

        if tNear > tFar {
            return false
        }
        
        let near = line.projectedNormalizedMagnitude(tNear)
        let far = line.projectedNormalizedMagnitude(tFar)
        
        let nearNormDotLine = normalMagnitude(for: near).dot(lineSlope)
        let farNormDotLine = normalMagnitude(for: far).dot(lineSlope)
        
        return (line.containsProjectedNormalizedMagnitude(tNear) && nearNormDotLine != .zero) ||
               (line.containsProjectedNormalizedMagnitude(tFar) && farNormDotLine != .zero)
    }
}
