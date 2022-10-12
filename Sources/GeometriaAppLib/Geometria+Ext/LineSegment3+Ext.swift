#if canImport(Geometria)
import Geometria
#endif

extension LineSegment3 where Vector: Vector3Real, Vector.Scalar == Double {
    
    /// Rotates this line segment around the origin using a given rotation
    /// matrix.
    @inlinable
    public func rotatedBy(_ matrix: RRotationMatrix3D) -> Self {
        let aT = matrix.transformPoint(start)
        let bT = matrix.transformPoint(end)
        
        return Self(start: aT, end: bT)
    }
    
    /// Rotates this line segment around a center point using a given rotation
    /// matrix.
    @inlinable
    public func rotatedBy(_ matrix: RRotationMatrix3D, around center: Vector) -> Self {
        let aT = matrix.transformPoint(start - center) + center
        let bT = matrix.transformPoint(end - center) + center
        
        return Self(start: aT, end: bT)
    }
}
