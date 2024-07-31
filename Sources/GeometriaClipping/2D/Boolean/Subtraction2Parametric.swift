import Geometria

/// A Union boolean parametric that joins two shapes into a single shape, if they
/// intersect in space.
public struct Subtraction2Parametric: Boolean2Parametric {
    public typealias Vector = Vector2D
    public typealias Contour = Parametric2Contour<Vector>

    public let lhsContours: [Contour]
    public let rhsContours: [Contour]
    public let tolerance: Scalar

    public init<T1: ParametricClip2Geometry, T2: ParametricClip2Geometry>(
        _ lhs: T1,
        _ rhs: T2,
        tolerance: T1.Scalar = .leastNonzeroMagnitude
    ) where T1.Vector == T2.Vector, T1.Vector == Vector, T1.Vector: Hashable {
        self.init(
            lhsContours: lhs.allContours(),
            rhsContours: rhs.allContours(),
            tolerance: tolerance
        )
    }

    public init(
        lhsContours: [Contour],
        rhsContours: [Contour],
        tolerance: Scalar = .leastNonzeroMagnitude
    ) {
        self.lhsContours = lhsContours
        self.rhsContours = rhsContours
        self.tolerance = tolerance
    }

    @inlinable
    public func allContours() -> [Contour] {
        let rhsReversed = rhsContours.map({ $0.reversed() })

        // A subtraction is a union of a geometry and a reverse-wound input geometry
        let union = Union2Parametric(
            contours: lhsContours + rhsReversed,
            tolerance: tolerance
        )
        return union.allContours()
    }

    @inlinable
    public static func subtraction<T1: ParametricClip2Geometry, T2: ParametricClip2Geometry>(
        tolerance: Vector.Scalar = .leastNonzeroMagnitude,
        _ lhs: T1,
        _ rhs: T2
    ) -> Compound2Parametric where T1.Vector == T2.Vector, T1.Vector == Vector, T1.Vector: Hashable {
        let op = Self(lhs, rhs, tolerance: tolerance)
        return .init(contours: op.allContours())
    }
}

/// Performs a subtraction operation by removing all given parametric geometries
/// from `shape1`.
@inlinable
public func subtraction(
    tolerance: Double = .leastNonzeroMagnitude,
    _ shape1: any ParametricClip2Geometry,
    _ shapes: [any ParametricClip2Geometry]
) -> Compound2Parametric {
    let shapes = shapes
        .map({ Compound2Parametric($0.reversed()) })

    return union(tolerance: tolerance, [Compound2Parametric(shape1)] + shapes)
}

/// Performs a subtraction operation across all given parametric contours.
@inlinable
public func subtraction(
    tolerance: Vector2D.Scalar = .leastNonzeroMagnitude,
    _ shape1: [Parametric2Contour<Vector2D>],
    _ shapes: [Parametric2Contour<Vector2D>]
) -> Compound2Parametric {
    let shapes = shapes.map({ $0.reversed() })

    return union(tolerance: tolerance, shape1 + shapes)
}
