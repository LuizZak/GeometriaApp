import Geometria

/// A Union boolean parametric that joins two shapes into a single shape, if they
/// intersect in space.
public struct Subtraction2Parametric: Boolean2Parametric {
    public typealias Period = Double

    public let lhs: T1, rhs: T2
    public let tolerance: Scalar

    public init(_ lhs: T1, _ rhs: T2, tolerance: T1.Scalar) {
        self.lhs = lhs
        self.rhs = rhs
        self.tolerance = tolerance
    }

    public func allContours() -> [Contour] {
        typealias State = GeometriaClipping.State

        let rhsReversed = rhs.reversed()

        // A subtraction is a union of a geometry and a reverse-wound input geometry
        return Union2Parametric(lhs, rhsReversed, tolerance: tolerance).allContours()
    }
}
