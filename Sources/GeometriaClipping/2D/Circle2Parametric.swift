import Geometria
import RealModule

/// A parametric geometry that is defined by a ``Circle2`` shape.
public struct Circle2Parametric: ParametricClip2Geometry, Equatable {
    public typealias Vector = Vector2D
    public typealias Scalar = Vector.Scalar
    public typealias Simplex = Parametric2GeometrySimplex
    public typealias Contour = Parametric2Contour

    public var description: String {
        "\(type(of: self))(circle2: \(circle2), isReversed: \(isReversed), startPeriod: \(startPeriod), endPeriod: \(endPeriod))"
    }

    /// The underlying circle shape that comprises this parametric geometry.
    public var circle2: Circle2<Vector>
    @usableFromInline
    var isReversed: Bool = false

    public var startPeriod: Period
    public var endPeriod: Period

    @inlinable
    public var center: Vector {
        circle2.center
    }

    @inlinable
    public var radius: Scalar {
        circle2.radius
    }

    @inlinable
    public var bounds: AABB<Vector> {
        circle2.bounds
    }

    public init(
        center: Vector,
        radius: Scalar,
        startPeriod: Period,
        endPeriod: Period
    ) {
        self.init(
            circle2: .init(
                center: center,
                radius: radius
            ),
            startPeriod: startPeriod,
            endPeriod: endPeriod
        )
    }

    public init(
        circle2: Circle2<Vector>,
        startPeriod: Period,
        endPeriod: Period
    ) {
        self.circle2 = circle2
        self.startPeriod = startPeriod
        self.endPeriod = endPeriod
    }

    @inlinable
    public func contains(_ point: Vector) -> Bool {
        circle2.contains(point)
    }

    @inlinable
    public func isOnSurface(_ point: Vector, toleranceSquared: Scalar) -> Bool {
        circle2.distanceSquared(to: point) < toleranceSquared
    }

    @inlinable
    public func allContours() -> [Contour] {
        return [
            .init(
                simplexes: allSimplexes(),
                winding: isReversed ? .counterClockwise : .clockwise
            )
        ]
    }

    @inlinable
    public func allSimplexes() -> [Simplex] {
        var arc1: CircleArc2<Vector>
        var arc2: CircleArc2<Vector>
        var arc3: CircleArc2<Vector>
        var arc4: CircleArc2<Vector>

        if isReversed {
            arc1 = circle2.arc(
                startAngle: .pi * 2,
                sweepAngle: -.pi / 2
            )
            arc2 = circle2.arc(
                startAngle: .pi * 3 / 2,
                sweepAngle: -.pi / 2
            )
            arc3 = circle2.arc(
                startAngle: .pi,
                sweepAngle: -.pi / 2
            )
            arc4 = circle2.arc(
                startAngle: .pi / 2,
                sweepAngle: -.pi / 2
            )
        } else {
            arc1 = circle2.arc(
                startAngle: .zero,
                sweepAngle: .pi / 2.0
            )
            arc2 = circle2.arc(
                startAngle: Angle.pi / 2.0,
                sweepAngle: .pi / 2.0
            )
            arc3 = circle2.arc(
                startAngle: .pi,
                sweepAngle: Angle.pi / 2.0
            )
            arc4 = circle2.arc(
                startAngle: .pi * 3 / 2,
                sweepAngle: .pi / 2
            )
        }

        let arcs = [arc1, arc2, arc3, arc4]
        let simplexes: [Simplex] = arcs.enumerated().map { (i, arc) in
            let startPeriod: Scalar = Scalar(i) / Scalar(arcs.count)
            let endPeriod: Scalar = Scalar(i + 1) / Scalar(arcs.count)

            return .circleArc2(
                .init(
                    circleArc: arc,
                    startPeriod: startPeriod,
                    endPeriod: endPeriod
                )
            )
        }

        return simplexes
    }

    @inlinable
    public func reversed() -> Self {
        var copy = self
        copy.isReversed = !isReversed
        return copy
    }
}
