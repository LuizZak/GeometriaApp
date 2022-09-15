#if canImport(Geometria)
import Geometria
#endif

extension Matrix4x4 {
    /// Initializes a 4x4 matrix with a given 3x3 matrix, aligned to the top-right
    /// of this matrix, with the remaining scalars filled with the values of the
    /// identity matrix.
    @inlinable
    public init(matrix3x3: Matrix3x3D) {
        self.init(rows: (
            Vector4(matrix3x3.r0Vec, w: 0),
            Vector4(matrix3x3.r1Vec, w: 0),
            Vector4(matrix3x3.r2Vec, w: 0),
            Vector4((0, 0, 0, 1))
        ))
    }
    
    /// Applies a given [rotation matrix] to this 4x4 matrix, with an option to
    /// apply a rotation around a given center point, instead of the origin.
    ///
    /// `prepend` defines whether the resulting matrix should be multiplied to
    /// the left or the right side of this matrix.
    ///
    /// [rotation matrix]: https://en.wikipedia.org/wiki/Rotation_matrix
    public func applying3DRotation<Vector: Vector3Real>(
        _ matrix: RRotationMatrix3D,
        around center: Vector,
        prepend: Bool = false
    ) -> Self where Vector.Scalar == Scalar {
        
        let rot = Self.init(matrix3x3: matrix)
        let tr = Self.makeTranslation(center)
        let trN = Self.makeTranslation(-center)
        
        let mat = tr * rot * trN
        
        if prepend {
            return mat * self
        }
        
        return self * mat
    }
}
