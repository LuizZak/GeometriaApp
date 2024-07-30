import MiniDigraph
import Geometria

/// An exclusive disjunction, or 'xor'- parametric combination that returns all
/// contours that are occupied by any one contour but not another.
public struct ExclusiveDisjunction2Parametric: Boolean2Parametric {
    public typealias Vector = Vector2D
    public typealias Contour = Parametric2Contour<Vector>

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
        /*
        typealias Graph = Simplex2Graph

        var graph = Graph.fromParametricIntersections(
            contours: contours,
            tolerance: tolerance
        )

        // Remove all edges that have incompatible total windings according to
        // their contour windings
        for edge in graph.edges {
            let shouldRemove: Bool

            switch edge.winding {
            case .clockwise:
                shouldRemove = edge.totalWinding != 1

                if edge.totalWinding == 2 {
                    let newEdge = edge.inverted(
                        edgeId: graph.nextEdgeId()
                    )
                    graph.addEdge(newEdge)
                }

            case .counterClockwise:
                shouldRemove = edge.totalWinding != 0
            }

            if shouldRemove {
                graph.removeEdge(edge)
            }
        }

        graph.prune()

        return graph.recombine()
        // */

        //*
        // An exclusive disjunction can be expressed as a union followed by a
        // subtraction of the intersection
        let union = union(tolerance: tolerance, self.contours)
        let intersection = intersection(tolerance: tolerance, self.contours)

        return subtraction(union, [intersection]).allContours()
        // */
    }

    @inlinable
    public static func xor<T1: ParametricClip2Geometry, T2: ParametricClip2Geometry>(
        tolerance: Vector.Scalar = .leastNonzeroMagnitude,
        _ lhs: T1,
        _ rhs: T2
    ) -> Compound2Parametric where T1.Vector == T2.Vector, T1.Vector == Vector, T1.Vector: Hashable {
        let op = Self(lhs, rhs, tolerance: tolerance)
        return .init(contours: op.allContours())
    }
}

/// Performs an exclusive disjunction, or 'xor'- operation across all given
/// parametric geometries.
///
/// - precondition: `shapes` is not empty.
@inlinable
public func xor(
    tolerance: Double = .leastNonzeroMagnitude,
    _ shapes: [any ParametricClip2Geometry]
) -> Compound2Parametric {
    let op = ExclusiveDisjunction2Parametric(
        contours: shapes.flatMap({ $0.allContours() }),
        tolerance: tolerance
    )

    return Compound2Parametric(
        contours: op.allContours()
    )
}

/// Performs an exclusive disjunction, or 'xor'- operation across all given
/// parametric contours.
///
/// - precondition: `contours` is not empty.
@inlinable
public func xor(
    tolerance: Double = .leastNonzeroMagnitude,
    _ contours: [Parametric2Contour<Vector2D>]
) -> Compound2Parametric {
    let op = ExclusiveDisjunction2Parametric(
        contours: contours,
        tolerance: tolerance
    )

    return Compound2Parametric(
        contours: op.allContours()
    )
}
