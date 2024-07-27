import Geometria
import RealModule

/// A 2-dimensional simplex composed of a circular arc segment.
public struct CircleArc2Simplex<Vector: Vector2Real>: Parametric2Simplex, Equatable {
    public typealias Scalar = Vector.Scalar

    public var description: String {
        "\(type(of: self))(circleArc: \(circleArc), startPeriod: \(startPeriod), endPeriod: \(endPeriod))"
    }

    /// The circular arc segment associated with this simplex.
    public var circleArc: CircleArc2<Vector> {
        didSet { bounds = circleArc.bounds() }
    }
    internal(set) public var bounds: AABB2<Vector>

    public var startPeriod: Period
    public var endPeriod: Period

    @inlinable
    public var center: Vector {
        circleArc.center
    }

    @inlinable
    public var radius: Scalar {
        circleArc.radius
    }

    @inlinable
    public var startAngle: Angle<Double> {
        circleArc.startAngle
    }

    @inlinable
    public var sweepAngle: Angle<Double> {
        circleArc.sweepAngle
    }

    @inlinable
    public var stopAngle: Angle<Double> {
        circleArc.stopAngle
    }

    @inlinable
    var lengthSquared: Scalar {
        circleArc.arcLength * circleArc.arcLength
    }

    /// Initializes a new circular arc segment simplex value with a given circular
    /// arc segment.
    public init(
        circleArc: CircleArc2<Vector>,
        startPeriod: Period,
        endPeriod: Period
    ) {
        self.circleArc = circleArc
        self.bounds = circleArc.bounds()
        self.startPeriod = startPeriod
        self.endPeriod = endPeriod
    }

    /// Returns `(period - startPeriod) / (endPeriod - startPeriod)`.
    ///
    /// - note: The result is unclamped.
    @inlinable
    func ratioForPeriod(_ period: Period) -> Period {
        (period - startPeriod) / (endPeriod - startPeriod)
    }

    /// Returns `startPeriod + (endPeriod - startPeriod) * ratio`.
    ///
    /// - note: The result is unclamped.
    @inlinable
    func period(onRatio ratio: Period) -> Period {
        startPeriod + (endPeriod - startPeriod) * ratio
    }

    @inlinable
    public func compute(at period: Period) -> Vector {
        let ratio = ratioForPeriod(period)

        let magnitude = circleArc.sweepAngle.radians * ratio

        return circleArc.pointOnAngle(
            circleArc.startAngle + magnitude
        )
    }

    @inlinable
    public func isOnSurface(_ vector: Vector, toleranceSquared: Scalar) -> Bool {
        circleArc.distanceSquared(to: vector) < toleranceSquared
    }

    /// Clamps this simplex so its contained geometry is only present within a
    /// given period range.
    ///
    /// If the geometry is not available on the given range, `nil` is returned,
    /// instead.
    @inlinable
    public func clamped(in range: Range<Period>) -> Self? {
        if startPeriod >= range.upperBound || endPeriod <= range.lowerBound {
            return nil
        }

        let ratioStart = max(ratioForPeriod(range.lowerBound), .zero)
        let ratioEnd = min(ratioForPeriod(range.upperBound), 1)

        return .init(
            circleArc: .init(
                center: circleArc.center,
                radius: circleArc.radius,
                startAngle: circleArc.startAngle + circleArc.sweepAngle * ratioStart,
                sweepAngle: circleArc.sweepAngle * (ratioEnd - ratioStart)
            ),
            startPeriod: max(startPeriod, range.lowerBound),
            endPeriod: min(endPeriod, range.upperBound)
        )
    }

    @inlinable
    public func reversed() -> Self {
        return .init(
            circleArc: .init(
                center: circleArc.center,
                radius: circleArc.radius,
                startAngle: circleArc.stopAngle,
                sweepAngle: -circleArc.sweepAngle
            ),
            startPeriod: startPeriod,
            endPeriod: endPeriod
        )
    }
}

extension CircleArc2Simplex {
    /// Converts the circular arc represented by this circular arc simplex into
    /// its full circular representation.
    @inlinable
    public var asCircle2: Circle2<Vector> {
        circleArc.asCircle2
    }

    @inlinable
    public var start: Vector { circleArc.startPoint }

    @inlinable
    public var end: Vector { circleArc.endPoint }
}
