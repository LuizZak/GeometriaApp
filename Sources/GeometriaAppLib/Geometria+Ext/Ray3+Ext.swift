#if canImport(Geometria)
import Geometria
#endif

extension Ray3 where Vector: Vector3Real, Vector.Scalar == Double {
    
    /// Rotates this ray around the origin using a given rotation matrix.
    @inlinable
    public func rotatedBy(_ matrix: RotationMatrix3D) -> Self {
        let aT = matrix.transformPoint(start)
        let bT = matrix.transformPoint(b)
        
        return Self(start: aT, b: bT)
    }
    
    /// Rotates this directional ray around a center point using a given rotation
    /// matrix.
    @inlinable
    public func rotatedBy(_ matrix: RotationMatrix3D, around center: Vector) -> Self {
        let aT = matrix.transformPoint(start - center) + center
        let bT = matrix.transformPoint(b - center) + center
        
        return Self(start: aT, b: bT)
    }
}
