import ImagineUI
import Geometria

/**
A 2D geometric type that exposes a function that maps the contiguous outer
edge of the shape within a period, and supports point containment checks.

## Shape

- Defined as a contiguous, periodic range of points that form a closed shape in two dimensions;
    - Periods range from [0 - 1), 0 inclusive and 1 exclusive;
    - Periods are modulo-1 arithmetic values that wrap around.
- Function P(p) that takes a period 'p' and produces a point on the shape.
    - Is contiguous with respect to input 'p'.
    - Is periodic- P(0) = P(1), P(0.5) = P(1.5), etc.
        - The output of negative periods is not specified.

## Intersector

- Defined with respect to two shapes to intersect, 's1' and 's2';
    - Produces intersection points as periods on each shape.
- Function Next(s, p), which takes as input one of the shapes 's1' or 's2' as 's' and gives the next
  intersection point period for that shape, starting from 'p';
- Function Prev(s, p), which works the same as Next(s, p), but produces the previous intersection period
  from input 'p' instead of the next;
    - These intersection functions can be used to 'walk' around a shape, examining intersection points,
      before wrapping around to the first intersection point.
- Function Contains(s, p), which takes as input one of the shapes 's1' or 's2' as 's' and a period 'p' on
  's', and returns a true or false value depending on whether the point defined by 's.P(p)' is fully
  contained by the other shape of the intersection that is not 's'.

## Shape Drawer

- Defined as the renderer function for strokes;
- Function Stroke(s, n, m), which takes as input a shape 's' and two periods 'n' and 'm' with respect to
  's', and strokes a contiguous path, starting from 'n' through 'm';
    - Always draws in positive direction; if value 'n' is greater than 'm', the shape drawer wraps around
      towards the 0th period, before proceeding through 'm'.
*/
public protocol PolyBooleanType: GeometricType, PeriodicSurfaceType {
    /// Returns `true` if the given point is contained within the surface of this
    /// geometry, including on its surface.
    func contains(_ point: Vector) -> Bool

    /// Returns `true` if `point` is close to the surface of this geometry, up
    /// to `tolerance` in precision.
    func isOnSurface(_ point: Vector, tolerance: Double) -> Bool
}

/// A periodic surface object.
public protocol PeriodicSurfaceType {
    /// The period type.
    ///
    /// Must be a comparable, numeric-convertible type that is expressible in the
    /// range [0 - 1], inclusive.
    typealias Period = Double
    typealias Vector = Vector2D

    func point(at period: Period) -> Vector
    func stroke(in range: ClosedRange<Period>) -> PeriodicSurfaceStroke

    /// Returns the result of `self.stroke(in: 0...1)`.
    func fullStroke() -> PeriodicSurfaceStroke
}

public extension PeriodicSurfaceType {
    func fullStroke() -> PeriodicSurfaceStroke {
        stroke(in: 0...1)
    }
}

/// Specifies a stroke operation for a periodic surface segment.
public struct PeriodicSurfaceStroke {
    public typealias Period = Double

    /// The start period of this stroke on its attached surface.
    ///
    /// Must be >= 0.0 and less than `end`.
    public var start: Period

    /// The end period of this stroke on its attached surface.
    ///
    /// Must be <= 1.0 and greater than `start`.
    public var end: Period

    /// The operation that this stroke performs during its stroke.
    public var op: Op

    /// Gets the total length of this stroke.
    public var length: Double {
        op.length
    }

    /// Returns `true` if this stroke surface is fully periodic, i.e. it covers
    /// the entire range between 0.0 and 1.0, inclusively.
    public var isFullyPeriodic: Bool {
        return start == 0 && end == 1.0
    }

    public init(start: Period, end: Period, op: Op) {
        self.start = start
        self.end = end
        self.op = op

        _assertValid()
    }

    func _assertValid() {
        #if DEBUG

        switch op {
        case .compound(let inner):
            let thresholdSquared: Double = 10 * 10
            inner._assertIsConnected(thresholdSquared: thresholdSquared)

        default:
            break
        }

        #endif
    }

    /// Returns `true` if this periodic stroke contains the given period value.
    /// In case this periodic stroke is fully periodic, the return is always
    /// `true`, as the value is implicitly wrapped around the range 0.0 and 1.0.
    func contains(period: Period) -> Bool {
        if isFullyPeriodic {
            return true
        }

        return start <= period && end >= period
    }

    /// Returns `start + (end - start) * factor`.
    func period(factor: Double) -> Double {
        start + (end - start) * factor
    }

    func compute(at period: Period) -> UIPoint {
        op.compute(at: period)
    }

    func closestPeriod(to point: UIPoint) -> (period: Double, distance: Double) {
        let (period, distance) = op.closestPeriod(to: point)
        let length = end - start

        return (start + (length) * period, distance)
    }

    /// Returns the result of clipping this stroke surface within a given range.
    ///
    /// If the range is outside the range of this stroke surface's start-end range,
    /// `nil` is returned, instead.
    public func clip(_ range: ClosedRange<Period>) -> Self? {
        if start > range.upperBound || end < range.lowerBound {
            return nil
        }

        guard let newOp = op.clip(range) else {
            return nil
        }

        return .init(start: range.lowerBound, end: range.upperBound, op: newOp)
    }

    /// The stroke operation of a periodic surface stroke.
    public enum Op {
        /// A straight line.
        case line(UILine)

        /// A circular arc.
        case circleArc(UICircleArc)

        /// A set of sub-strokes that encompass a single stroke operation.
        ///
        /// The total period of all strokes is always assumed to be in sequential
        /// order, from lowest to highest, with no gaps, and if this operation is
        /// associated with a `PeriodicSurfaceStroke`, the period range is equal
        /// to that periodic stroke's `start` and `end` periods.
        case compound([PeriodicSurfaceStroke.Op])

        var asUILine: UILine? {
            switch self {
            case .line(let line): return line
            default: return nil
            }
        }

        var asUICircleArc: UICircleArc? {
            switch self {
            case .circleArc(let arc): return arc
            default: return nil
            }
        }

        /// Gets the total length of this stroke path operation.
        var length: Double {
            switch self {
            case .line(let line):
                return line.length()

            case .circleArc(let arc):
                return arc.length()

            case .compound(let strokes):
                return strokes.reduce(0) { $0 + $1.length }
            }
        }

        func operation(at period: Period) -> Self {
            switch self {
            case .line, .circleArc:
                return self

            case .compound(let ops):
                let relative = ops
                    .relativePeriods()

                for (range, op) in relative {
                    guard range.contains(period) else {
                        continue
                    }

                    return op
                }

                return self
            }
        }

        func compute(at period: Period) -> UIPoint {
            switch self {
            case .line(let line):
                return line * period

            case .circleArc(let arc):
                let angle = arc.sweepAngle * period

                return arc.pointOnAngle(arc.startAngle + angle)

            case .compound(let ops):
                let relative = ops
                    .relativePeriods()

                for (range, op) in relative {
                    guard range.contains(period) else {
                        continue
                    }

                    let length = (range.upperBound - range.lowerBound)
                    let factor = (period - range.lowerBound) / length

                    return op.compute(at: factor)
                }

                return .zero
            }
        }

        func closestPeriod(to point: UIPoint) -> (period: Double, distance: Double) {
            switch self {
            case .line(let line):
                let lineSegment = line.asLineSegment2D
                let scalar = lineSegment.clampProjectedNormalizedMagnitude(
                    lineSegment.projectAsScalar(point.asVector2D)
                )

                let ratio = scalar
                let pointOnLine = lineSegment.projectedNormalizedMagnitude(scalar)
                let distance = pointOnLine.distance(to: point.asVector2D)

                assert(
                    pointOnLine.distance(to: compute(at: ratio).asVector2D) <= (distance * 2 + 1e-12),
                    "Attempting to return closest period to line with mismatched point?"
                )

                return (ratio, distance: distance)

            case .circleArc(let arc):
                let angle = UIAngle(radians: (point - arc.center).angle()).radians
                let sweep = UIAngleSweep(start: .init(radians: arc.startAngle), sweep: arc.sweepAngle)

                // Full circle
                guard arc.sweepAngle < .pi * 2 else {
                    let pointOnArc = arc.circle.projectOnPerimeter(point)
                    let period = angle / (.pi * 2)
                    let distance = pointOnArc.distance(to: point)

                    return (period.normalizedPeriod(), distance)
                }

                let clamped = sweep.clamped(.init(radians: angle))

                let ratio = (
                    sweep.relativeToStart(clamped) / arc.sweepAngle
                ).normalizedPeriod()

                let pointOnArc = arc.pointOnAngle(clamped.radians)
                let distance = pointOnArc.distance(to: point)

                assert(
                    pointOnArc.distance(to: compute(at: ratio)) <= (distance * 2 + 1e-12),
                    "Attempting to return closest period to arc with mismatched point?"
                )

                return (ratio, distance)

            case .compound(let strokes):
                let relative = strokes
                    .relativePeriods()

                var closest: (period: Double, distance: Double) = (0, .infinity)
                for (range, op) in relative {
                    let length = (range.upperBound - range.lowerBound)
                    let opDist = op.closestPeriod(to: point)
                    let opPeriod = range.lowerBound + opDist.period * length

                    if opDist.distance < closest.distance {
                        closest = (opPeriod, opDist.distance)
                    }
                }

                assert(
                    closest.distance.isInfinite || point.distance(to: compute(at: closest.period)) <= (closest.distance * 2 + 1e-12),
                    "Attempting to return closest period to line with mismatched point?"
                )

                return closest
            }
        }

        func clip(_ range: ClosedRange<Period>) -> Self? {
            switch self {
            case .line(let line):
                let start = line * range.lowerBound
                let end = line * range.upperBound

                return .line(.init(start: start, end: end))

            case .circleArc(let arc):
                let start = arc.startAngle + arc.sweepAngle * range.lowerBound
                let sweep = arc.sweepAngle * (range.upperBound - range.lowerBound)

                return .circleArc(
                    .init(center: arc.center, radius: arc.radius, startAngle: start, sweepAngle: sweep)
                )

            case .compound(let ops):
                let relative = ops
                    .relativePeriods()

                let ops: [Self] = relative.compactMap { (period, op) in
                    if period.upperBound < range.lowerBound || period.lowerBound > range.upperBound {
                        return nil
                    }
                    if range.lowerBound <= period.lowerBound && range.upperBound >= period.upperBound {
                        return op
                    }

                    let innerRange: ClosedRange<Period>
                    if period.upperBound > range.upperBound {
                        let relative = period.relative(range.upperBound)
                        innerRange = 0...relative
                    } else {
                        let relative = period.relative(range.lowerBound)
                        innerRange = relative...1
                    }

                    return op.clip(innerRange)
                }
                if ops.isEmpty {
                    return nil
                }
                if ops.count == 1 {
                    return ops[0]
                }

                return .compound(ops)
            }
        }

        /// Recursively collects all points referenced by this stroke operation.
        ///
        /// The method only collects discrete points used in line/arc end points,
        /// and not the points formed by their strokes.
        func collectPoints(_ target: inout [UIPoint]) {
            switch self {
            case .line(let line):
                target.append(line.start)
                target.append(line.end)

            case .circleArc(let arc):
                target.append(arc.startPoint)
                target.append(arc.endPoint)

            case .compound(let ops):
                ops.forEach {
                    $0.collectPoints(&target)
                }
            }
        }

        func _validateIsConnected(_ next: Self, thresholdSquared: Double = 10.0 * 10.0) -> Bool {
            let atPrev = compute(at: 1.0)
            let atNext = next.compute(at: 0.0)
            let distanceSquared = atPrev.distanceSquared(to: atNext)

            return distanceSquared < thresholdSquared
        }
    }
}

extension Collection where Element == PeriodicSurfaceStroke.Op {
    typealias Period = Double

    func length() -> Double {
        reduce(0) { $0 + $1.length }
    }

    func flattened() -> [Element] {
        var result: [Element] = []

        for op in self {
            switch op {
            case .compound(let inner):
                result.append(contentsOf: inner.flattened())
            default:
                result.append(op)
            }
        }

        return result
    }

    func flattenedRelativePeriods() -> [(ClosedRange<Period>, PeriodicSurfaceStroke.Op)] {
        return flattened().relativePeriods()
    }

    func relativePeriods() -> [(ClosedRange<Period>, PeriodicSurfaceStroke.Op)] {
        var periods: [ClosedRange<Period>] = []
        let totalLength = length()
        var currentLength: Double = 0.0
        var current: Period = 0

        for op in self {
            currentLength += op.length
            let end = currentLength / totalLength

            periods.append(current...end)

            current = end
        }

        return Array(zip(periods, self))
    }
}

fileprivate extension ClosedRange where Bound == Double {
    func relative(_ value: Bound) -> Bound {
        let low = (value - lowerBound)
        let high = (upperBound - lowerBound)

        return low / high
    }

    func relative(_ range: Self) -> Self {
        let rangeLength = range.upperBound - range.lowerBound

        let low = (range.lowerBound - lowerBound)
        let high = (range.upperBound - lowerBound) * rangeLength

        return low...high
    }
}

fileprivate extension Double {
    func normalizedPeriod() -> Double {
        var value = self.truncatingRemainder(dividingBy: 1)
        while value < 0 {
            value += 1.0
        }
        return value
    }
}

#if DEBUG

internal extension Collection where Element == PeriodicSurfaceStroke.Op {
    func _assertIsConnected(thresholdSquared: Double = 10.0 * 10.0, file: StaticString = #file, line: UInt = #line) {
        let thresholdSquared: Double = 10 * 10
        for (prev, next) in zip(self, self.dropFirst()) {
            /*
            assert(
                prev._validateIsConnected(next, thresholdSquared: thresholdSquared),
                "Found compound shape that has sequential operations that are not connected?",
                file: file,
                line: line
            )
            */
        }
    }
}

#endif
