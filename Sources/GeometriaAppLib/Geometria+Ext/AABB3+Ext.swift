import RealModule
#if canImport(Geometria)
import Geometria
#endif

extension AABB3 where Self: DivisibleRectangleType, Vector: VectorComparable, Vector.Scalar == Double {
    /// Subdivides this AABB into its eight 3-dimensional octants with a middle
    /// split along each axis.
    ///
    /// The ordering of the octants is not defined.
    @inlinable
    public func octants() -> (Self, Self, Self, Self, Self, Self, Self, Self) {
        let center = self.center
        let vertices = self.vertices

        assert(vertices.count == 8)

        return (
            Self(of: center, vertices[0]),
            Self(of: center, vertices[1]),
            Self(of: center, vertices[2]),
            Self(of: center, vertices[3]),
            Self(of: center, vertices[4]),
            Self(of: center, vertices[5]),
            Self(of: center, vertices[6]),
            Self(of: center, vertices[7])
        )
    }
}

extension AABB3 where Vector: Vector3Real, Vector.Scalar == Double {
    
    /// Rotates this AABB around the origin using a given rotation matrix.
    @inlinable
    public func rotatedBy(_ matrix: RRotationMatrix3D) -> Self {
        let points = vertices.transformed(by: matrix)
        
        return Self(points: points)
    }
    
    /// Rotates this AABB around a center point using a given rotation matrix.
    @inlinable
    public func rotatedBy(_ matrix: RRotationMatrix3D, around center: Vector) -> Self {
        let points = vertices.map {
            matrix.transformPoint($0 - center) + center
        }
        
        return Self(points: points)
    }
}
