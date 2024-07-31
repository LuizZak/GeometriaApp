import Geometria

/// A Union boolean parametric that joins two shapes into a single shape, if they
/// intersect in space.
public struct Union2Parametric: Boolean2Parametric {
    public typealias Vector = Vector2D
    public typealias Contour = Parametric2Contour

    public let contours: [Contour]
    public let tolerance: Scalar

    public init<T1: ParametricClip2Geometry, T2: ParametricClip2Geometry>(
        _ lhs: T1,
        _ rhs: T2,
        tolerance: T1.Scalar = .leastNonzeroMagnitude
    ) where T1.Vector == T2.Vector, T1.Vector == Vector, T1.Vector: Hashable {
        self.init(
            contours: lhs.allContours() + rhs.allContours(),
            tolerance: tolerance
        )
    }

    public init(
        contours: [Contour],
        tolerance: Scalar = .leastNonzeroMagnitude
    ) {
        self.contours = contours
        self.tolerance = tolerance
    }

    @inlinable
    public func allContours() -> [Contour] {
        typealias Graph = Simplex2Graph

        let graph = Graph.fromParametricIntersections(
            contours: contours,
            tolerance: tolerance
        )

        return graph.recombine { edge in
            switch edge.winding {
            case .clockwise:
                return edge.totalWinding == 1

            case .counterClockwise:
                return edge.totalWinding == 0
            }
        }
    }

    @inlinable
    static func union<T1: ParametricClip2Geometry, T2: ParametricClip2Geometry>(
        tolerance: Vector.Scalar = .leastNonzeroMagnitude,
        _ lhs: T1,
        _ rhs: T2
    ) -> Compound2Parametric where T1.Vector == T2.Vector, T1.Vector == Vector, T1.Vector: Hashable {
        let op = Self(lhs, rhs, tolerance: tolerance)
        return .init(contours: op.allContours())
    }
}

/// Performs a union operation across all given parametric geometries.
@inlinable
public func union(
    tolerance: Vector2D.Scalar = .leastNonzeroMagnitude,
    _ shapes: [any ParametricClip2Geometry]
) -> Compound2Parametric {
    let op = Union2Parametric(
        contours: shapes.flatMap({ $0.allContours() }),
        tolerance: tolerance
    )

    return Compound2Parametric(
        contours: op.allContours()
    )
}

/// Performs a union operation across all given parametric contours.
@inlinable
public func union(
    tolerance: Vector2D.Scalar = .leastNonzeroMagnitude,
    _ contours: [Parametric2Contour]
) -> Compound2Parametric {
    let op = Union2Parametric(
        contours: contours,
        tolerance: tolerance
    )

    return Compound2Parametric(
        contours: op.allContours()
    )
}
