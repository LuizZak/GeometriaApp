#if canImport(Geometria)
import Geometria
#endif

extension Line3 where Vector: Vector3Real, Vector.Scalar == Double {
    
    /// Rotates this line around the origin using a given rotation matrix.
    @inlinable
    public func rotated(by matrix: RRotationMatrix3D) -> Self {
        let aT = matrix.transformPoint(self.a)
        let bT = matrix.transformPoint(self.b)
        
        return Self(a: aT, b: bT)
    }
    
    /// Rotates this line around a center point using a given rotation matrix.
    @inlinable
    public func rotated(by matrix: RRotationMatrix3D, around center: Vector) -> Self {
        let aT = matrix.transformPoint(a - center) + center
        let bT = matrix.transformPoint(b - center) + center
        
        return Self(a: aT, b: bT)
    }
}
