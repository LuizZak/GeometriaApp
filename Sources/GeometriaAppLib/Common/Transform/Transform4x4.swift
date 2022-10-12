#if canImport(Geometria)
import Geometria
#endif

/// Encodes a 4x4 matrix and its inverse.
public typealias Transform4x4 = TransformMatrix<RMatrix4x4>

extension Transform4x4 {
    public func transformPoint<Vector: Vector3FloatingPoint>(_ vec: Vector) -> Vector where Vector.Scalar == Matrix.Scalar {
        m.transformPoint(vec)
    }
    
    public func transformVector<Vector: Vector3FloatingPoint>(_ vec: Vector) -> Vector where Vector.Scalar == Matrix.Scalar {
        m.transformVector(vec)
    }
    
    public func transformNormal<Vector: Vector3FloatingPoint>(_ vec: Vector) -> Vector where Vector.Scalar == Matrix.Scalar {
        mInv.transformVector(vec)
    }
    
    public func transformNormal<Vector: Vector4FloatingPoint>(_ vec: Vector) -> Vector where Vector.Scalar == Matrix.Scalar {
        mInv.transformPoint(vec)
    }
}
