#if canImport(Geometria)
import Geometria
#endif

/// Encodes a square matrix and its inverse.
public struct TransformMatrix<Matrix: SquareMatrixType> {
    public let m: Matrix
    
    /// Inverse of `self.m`
    public let mInv: Matrix

    public init(_ m: Matrix) {
        self.init(m, m.inverted() ?? .identity)
    }

    @usableFromInline
    internal init(_ m: Matrix, _ mInv: Matrix) {
        self.m = m
        self.mInv = mInv
    }

    @inlinable
    public static func * (lhs: Self, rhs: Self) -> Self {
        TransformMatrix(
            lhs.m * rhs.m,
            lhs.mInv * rhs.mInv
        )
    }

    @inlinable
    public static func * (lhs: Self, rhs: Matrix) -> Self {
        lhs * TransformMatrix(rhs)
    }

    @inlinable
    public static func * (lhs: Matrix, rhs: Self) -> Self {
        TransformMatrix(lhs) * rhs
    }
}
