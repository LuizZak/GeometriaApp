#if canImport(Geometria)
import Geometria
#endif

extension DirectionalRay3 where Vector: Vector3Real, Vector.Scalar == Double {
    
    /// Rotates this directional ray around the origin using a given rotation
    /// matrix.
    @inlinable
    public func rotatedBy(_ matrix: RRotationMatrix3D) -> Self {
        let aT = matrix.transformPoint(start)
        let dirT = matrix.transformPoint(direction)
        
        return Self(start: aT, direction: dirT)
    }
    
    /// Rotates this directional ray around a center point using a given rotation
    /// matrix.
    @inlinable
    public func rotatedBy(_ matrix: RRotationMatrix3D, around center: Vector) -> Self {
        let aT = matrix.transformPoint(start - center) + center
        let dirT = matrix.transformPoint(direction)
        
        return Self(start: aT, direction: dirT)
    }
}
