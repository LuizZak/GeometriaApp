import ImagineUI
import Geometria

/// A 2D geometric type that exposes a function that maps the contiguous outer
/// edge of the shape within a period, and supports point containment checks.
public protocol PolyBooleanType: GeometricType, PeriodicSurfaceType {
    func contains(_ point: Vector) -> Bool
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

    /// Returns `true` if this stroke surface is fully periodic, i.e. it covers
    /// the entire range between 0.0 and 1.0, inclusively.
    public var isFullyPeriodic: Bool {
        return start == 0 && end == 1.0
    }

    public init(start: Period, end: Period, op: Op) {
        self.start = start
        self.end = end
        self.op = op
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
        let adjusted = (period - start) / (end - start)

        switch op {
        case .line(let line):
            return line * adjusted

        case .circleArc(let arc):
            let angle = arc.sweepAngle * adjusted

            return arc.pointOnAngle(arc.startAngle + angle)

        case .compound(let strokes):
            for stroke in strokes {
                if stroke.start <= period && stroke.end >= period {
                    return stroke.compute(at: period)
                }
            }

            guard let last = strokes.last else {
                return .zero
            }

            return last.compute(at: last.end)
        }
    }

    func closestPeriod(to point: UIPoint) -> (period: Double, distance: Double) {
        switch op {
        case .line(let line):
            let lineSegment = line.asLineSegment2D
            let scalar = lineSegment.clampProjectedNormalizedMagnitude(
                lineSegment.projectAsScalar(point.asVector2D)
            )
            let ratio = scalar
            let pointOnLine = lineSegment.projectedNormalizedMagnitude(scalar)

            let period = period(factor: ratio)
            let distance = pointOnLine.distance(to: point.asVector2D)

            return (period, distance: distance)

        case .circleArc(let arc):
            let angle = normalizeAngle((point - arc.center).angle())

            // Full circle
            guard arc.sweepAngle < .pi * 2 else {
                let pt = arc.circle.projectOnPerimeter(point)
                let period = (angle - arc.startAngle) / arc.sweepAngle
                let range = end - start

                return (start + period.truncatingRemainder(dividingBy: range), pt.distance(to: point))
            }

            // Normalize arc's angle representation
            let isMirrored: Bool
            let normalized: UICircleArc
            if arc.sweepAngle < 0 {
                normalized = arc.mirrored
                isMirrored = true
            } else {
                normalized = arc
                isMirrored = false
            }

            let clamped = clampAngle(angle, min: normalized.startAngle, max: normalized.stopAngle)

            let pointAt = normalized.pointOnAngle(clamped)
            var period = (clamped - normalized.startAngle) / normalized.sweepAngle
            if isMirrored {
                period = 1 - period
            }

            return (period, pointAt.distance(to: point))

        case .compound(let strokes):
            let distances = strokes
                .map({ $0.closestPeriod(to: point) })
                .sorted(by: {
                    $0.distance < $1.distance
                })

            return distances.first ?? (0, .infinity)
        }
    }

    /// Returns the result of clipping this stroke surface below a given period.
    ///
    /// If `period` is greater than `end`, `self` is returned, and if `period`
    /// is lower than `start`, `nil` is returned, instead.
    public func clipLower(period: Period) -> Self? {
        if period > end {
            return self
        }
        if period < start {
            return nil
        }

        let reduction = end - period

        let newOp: Op
        switch op {
        case .line(let line):
            let start = line.start
            let end = line * (end - reduction)

            newOp = .line(.init(start: start, end: end))

        case .circleArc(let arc):
            let start = arc.startAngle
            let end = arc.sweepAngle * (end - reduction)

            newOp = .circleArc(.init(center: arc.center, radius: arc.radius, startAngle: start, sweepAngle: end))

        case .compound(let strokes):
            let strokes = strokes.compactMap({ $0.clipLower(period: period) })

            assert(!strokes.isEmpty, "Unexpected empty strokes after \(#function)?")

            newOp = .compound(strokes)
        }

        return .init(start: start, end: period, op: newOp)
    }

    /// Returns the result of clipping this stroke surface above a given period.
    ///
    /// If `period` is lower than `start`, `self` is returned, and if `period`
    /// is greater than `end`, `nil` is returned, instead.
    public func clipHigher(period: Period) -> Self? {
        if period < start {
            return self
        }
        if period > end {
            return nil
        }

        let reduction = start - period

        let newOp: Op
        switch op {
        case .line(let line):
            let start = line * reduction
            let end = line.end

            newOp = .line(.init(start: start, end: end))

        case .circleArc(let arc):
            let start = arc.startAngle + arc.sweepAngle * reduction
            let end = arc.sweepAngle * reduction

            newOp = .circleArc(.init(center: arc.center, radius: arc.radius, startAngle: start, sweepAngle: end))

        case .compound(let strokes):
            let strokes = strokes.compactMap({ $0.clipHigher(period: period) })

            assert(!strokes.isEmpty, "Unexpected empty strokes after \(#function)?")

            newOp = .compound(strokes)
        }

        return .init(start: period, end: end, op: newOp)
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
        case compound([PeriodicSurfaceStroke])
    }
}

fileprivate func normalizeAngle(_ ang: Double) -> Double {
    var ang = ang

    while ang < -.pi {
        ang += .pi * 2
    }

    while ang >= .pi {
        ang -= .pi * 2
    }

    return ang
}

fileprivate func clampAngle(_ ang: Double, min: Double, max: Double) -> Double {
    let n_min = normalizeAngle(min - ang)
    let n_max = normalizeAngle(max - ang)

    if n_min <= 0 && n_max >= 0 {
        return ang
    }
    if n_min.magnitude < n_max.magnitude {
        return min
    }

    return max
}
