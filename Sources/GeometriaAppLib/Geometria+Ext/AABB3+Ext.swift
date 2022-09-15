import RealModule
#if canImport(Geometria)
import Geometria
#endif

extension AABB3 where Vector: Vector3Real, Vector.Scalar == Double {
    
    /// Rotates this AABB around the origin using a given rotation matrix.
    @inlinable
    public func rotated(by matrix: RRotationMatrix3D) -> Self {
        let points = vertices.transformed(by: matrix)
        
        return Self(points: points)
    }
    
    /// Rotates this AABB around a center point using a given rotation matrix.
    @inlinable
    public func rotated(by matrix: RRotationMatrix3D, around center: Vector) -> Self {
        let points = vertices.map {
            matrix.transformPoint($0 - center) + center
        }
        
        return Self(points: points)
    }
}
