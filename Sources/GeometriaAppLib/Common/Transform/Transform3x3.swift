#if canImport(Geometria)
import Geometria
#endif

/// Encodes a 3x3 matrix and its inverse.
public typealias Transform3x3 = TransformMatrix<RMatrix3x3>

extension Transform3x3 {
    public func transformPoint<Vector: Vector2FloatingPoint>(_ vec: Vector) -> Vector where Vector.Scalar == Matrix.Scalar {
        m.transformPoint(vec)
    }
    
    public func transformVector<Vector: Vector2FloatingPoint>(_ vec: Vector) -> Vector where Vector.Scalar == Matrix.Scalar {
        m.transformVector(vec)
    }
    
    public func transformNormal<Vector: Vector2FloatingPoint>(_ vec: Vector) -> Vector where Vector.Scalar == Matrix.Scalar {
        mInv.transformVector(vec)
    }
    
    public func transformNormal<Vector: Vector3FloatingPoint>(_ vec: Vector) -> Vector where Vector.Scalar == Matrix.Scalar {
        mInv.transformPoint(vec)
    }
}
