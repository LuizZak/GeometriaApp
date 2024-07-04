import Geometria
import Geometry

struct PolyIntersectResult {
    typealias Period = Double

    var pairs: [Pair]

    /// Returns `true` if this intersection result is empty.
    var isEmpty: Bool {
        pairs.isEmpty
    }

    /// Returns the sorted periods in relation to the left hand side of the
    /// intersection that this intersection result represents.
    func sortedLhsPeriods() -> [Period] {
        pairs.flatMap({ [$0.lhs.start, $0.lhs.end] }).sorted()
    }

    /// Returns the sorted periods in relation to the right hand side of the
    /// intersection that this intersection result represents.
    func sortedRhsPeriods() -> [Period] {
        pairs.flatMap({ [$0.rhs.start, $0.rhs.end] }).sorted()
    }

    func makeIterator() -> [Pair].Iterator {
        pairs.makeIterator()
    }

    /// The representation of the intersection in both `lhs` and `rhs`.
    struct Pair {
        /// The start and end period on the left-hand side of the intersection
        /// that this intersection result represents.
        var lhs: (start: Period, end: Period)

        /// The start and end period on the right-hand side of the intersection
        /// that this intersection result represents.
        ///
        /// - note: Start/end match the points on `lhs.start` and `lhs.end`, but
        /// are mirrored such that the period on `lhs.start` matches the period
        /// in `rhs.end`.
        var rhs: (end: Period, start: Period)
    }
}

class PolyIntersect {
    typealias Period = Double

    var maxDistanceThreshold: Double = 0.01
    let arcAdjacentThreshold: Double = 0.01
    let periodAdjacentThreshold: Double = 0.01

    func _intersect(_ lhs: any PolyBooleanType, lhsGeometryId: Int, _ rhs: any PolyBooleanType, rhsGeometryId: Int) -> [IntersectingPointOfInterestSource.Intersection] {
        typealias Result = IntersectingPointOfInterestSource.Intersection

        let intersect = intersect(lhs, rhs)

        let lhsPeriods = intersect.pairs.flatMap({ [$0.lhs.start, $0.lhs.end] })
        var rhsPeriods = intersect.pairs.flatMap({ [$0.rhs.start, $0.rhs.end] })

        var result: [Result] = []

        for lhsPeriod in lhsPeriods {
            let lhsPoint = lhs.point(at: lhsPeriod)

            var closest: (Int, distanceSquared: Double) = (-1, .infinity)
            for (i, rhsPeriod) in rhsPeriods.enumerated() {
                let rhsPoint = rhs.point(at: rhsPeriod)

                let distSquared = lhsPoint.distanceSquared(to: rhsPoint)

                if distSquared < closest.distanceSquared {
                    closest = (i, distSquared)
                }
            }

            let rhsPeriod = rhsPeriods[closest.0]
            rhsPeriods.remove(at: closest.0)

            let lhsOp = lhs.fullStroke().op.operation(at: lhsPeriod)
            let rhsOp = rhs.fullStroke().op.operation(at: rhsPeriod)

            let lhsOpKind = PointOfInterest.GeometryKind.fromPeriodicSurfaceStrokeOp(lhsOp)
            let rhsOpKind = PointOfInterest.GeometryKind.fromPeriodicSurfaceStrokeOp(rhsOp)

            let intersection = Result(
                point: lhsPoint.asUIPoint,
                geometry1: lhsGeometryId,
                geometry1Period: lhsPeriod,
                geometry1Kind: lhsOpKind,
                geometry2: rhsGeometryId,
                geometry2Period: rhsPeriod,
                geometry2Kind: rhsOpKind
            )
            result.append(intersection)
        }

        return result
    }

    func intersect(_ lhs: any PolyBooleanType, _ rhs: any PolyBooleanType) -> PolyIntersectResult {
        return intersect(lhs.fullStroke(), rhs.fullStroke())
    }

    func intersect<T1: PolyBooleanType, T2: PolyBooleanType>(_ lhs: T1, _ rhs: T2) -> PolyIntersectResult {
        return intersect(lhs.fullStroke(), rhs.fullStroke())
    }

    fileprivate func intersect(_ lhs: PeriodicSurfaceStroke, _ rhs: PeriodicSurfaceStroke) -> PolyIntersectResult {
        func clipPeriod(_ point: Vector2D, _ stroke: PeriodicSurfaceStroke) -> Period? {
            let (period, distance) = stroke.closestPeriod(to: point.asUIPoint)
            guard distance <= maxDistanceThreshold else {
                return nil
            }
            guard stroke.contains(period: period) else {
                return nil
            }

            return period
        }
        func isWithinThreshold(_ last: Double, _ next: Double) -> Bool {
            let diff = (last - next).magnitude
            return diff >= periodAdjacentThreshold
        }
        func isWithinThreshold(_ last: (Double, Double), _ next: (Double, Double)) -> Bool {
            return isWithinThreshold(last.0, next.0)
                || isWithinThreshold(last.1, next.1)
        }

        var result = PolyIntersectResult(pairs: [])
        var lhsPeriods: [Period] = []
        var rhsPeriods: [Period] = []

        let points = intersectionPoints(lhs.op, rhs.op)
        for point in points {
            if
                let lhsPeriod = clipPeriod(point, lhs),
                let rhsPeriod = clipPeriod(point, rhs)
            {
                lhsPeriods.append(lhsPeriod)
                rhsPeriods.append(rhsPeriod)
            }
        }

        lhsPeriods.sort()
        rhsPeriods.sort()

        lhsPeriods.removeDuplicates()
        rhsPeriods.removeDuplicates()

        var lastPeriod: (lhs: Period, rhs: Period)?
        for (lhsPeriod, rhsPeriod) in zip(lhsPeriods, rhsPeriods) {
            if let _lastPeriod = lastPeriod {
                if isWithinThreshold(_lastPeriod, (lhsPeriod, rhsPeriod)) {
                    result.pairs.append(
                        .init(
                            lhs: (_lastPeriod.lhs, lhsPeriod),
                            rhs: (rhsPeriod, _lastPeriod.rhs)
                        )
                    )

                    lastPeriod = nil
                }
            } else {
                lastPeriod = (lhsPeriod, rhsPeriod)
            }
        }

        return result
    }

    /*
    fileprivate func intersectionPeriods(_ lhs: PeriodicSurfaceStroke, _ rhs: PeriodicSurfaceStroke) -> [Period] {
        switch lhs.op {
        case .line(let lhsOp):
            break

        case .circleArc(let lhsOp):
            break

        case .compound(let lhsOp):
            break
        }
    }
    */

    fileprivate func intersectionPoints(_ lhs: PeriodicSurfaceStroke.Op, _ rhs: PeriodicSurfaceStroke.Op) -> [Vector2D] {
        switch lhs {
        case .line(let lhs):
            return intersectionPoints(lhs, rhs)

        case .circleArc(let lhs):
            return intersectionPoints(lhs, rhs)

        case .compound(let lhs):
            return intersectionPoints(lhs, rhs)
        }
    }

    fileprivate func intersectionPoints(_ lhs: [PeriodicSurfaceStroke.Op], _ rhs: [PeriodicSurfaceStroke.Op]) -> [Vector2D] {
        var result: [Vector2D] = []

        for lhs in lhs {
            for rhs in rhs {
                let points = intersectionPoints(lhs, rhs)
                result.append(contentsOf: points)
            }
        }

        return result
    }

    fileprivate func intersectionPoints(_ lhs: PeriodicSurfaceStroke.Op, _ rhs: [PeriodicSurfaceStroke.Op]) -> [Vector2D] {
        var result: [Vector2D] = []

        for rhs in rhs {
            let points = intersectionPoints(lhs, rhs)
            result.append(contentsOf: points)
        }

        return result
    }

    fileprivate func intersectionPoints(_ lhs: [PeriodicSurfaceStroke.Op], _ rhs: PeriodicSurfaceStroke.Op) -> [Vector2D] {
        var result: [Vector2D] = []

        for lhs in lhs {
            switch lhs {
            case .line(let lhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )

            case .circleArc(let lhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )

            case .compound(let lhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )
            }
        }

        return result
    }

    fileprivate func intersectionPoints(_ lhs: UILine, _ rhs: UILine) -> [Vector2D] {
        guard let intersection = lhs.asLineSegment2D.intersection(with: rhs.asLineSegment2D) else {
            return []
        }

        return [intersection.point]
    }

    fileprivate func intersectionPoints(_ lhs: UICircleArc, _ rhs: UILine) -> [Vector2D] {
        return intersectionPoints(rhs, lhs)
    }
    fileprivate func intersectionPoints(_ lhs: UILine, _ rhs: UICircleArc) -> [Vector2D] {
        let intersection = rhs.asCircle2D.intersection(with: lhs.asLineSegment2D)

        switch intersection {
        case .contained, .noIntersection:
            return []

        case .enter(let pn), .exit(let pn), .singlePoint(let pn):
            return [pn.point]

        case .enterExit(let enter, let exit):
            return [exit.point, enter.point]
        }
    }

    fileprivate func intersectionPoints(_ lhs: PeriodicSurfaceStroke.Op, _ rhs: UILine) -> [Vector2D] {
        return intersectionPoints(rhs, lhs)
    }
    fileprivate func intersectionPoints(_ lhs: UILine, _ rhs: PeriodicSurfaceStroke.Op) -> [Vector2D] {
        switch rhs {
        case .line(let rhs):
            return intersectionPoints(lhs, rhs)

        case .circleArc(let rhs):
            return intersectionPoints(lhs, rhs)

        case .compound(let rhs):
            return intersectionPoints(lhs, rhs)
        }
    }

    fileprivate func intersectionPoints(_ lhs: [PeriodicSurfaceStroke.Op], _ rhs: UILine) -> [Vector2D] {
        return intersectionPoints(rhs, lhs)
    }
    fileprivate func intersectionPoints(_ lhs: UILine, _ rhs: [PeriodicSurfaceStroke.Op]) -> [Vector2D] {
        var result: [Vector2D] = []

        for rhs in rhs {
            switch rhs {
            case .line(let rhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )

            case .circleArc(let rhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )

            case .compound(let rhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )
            }
        }

        return result
    }

    fileprivate func intersectionPoints(_ lhs: UICircleArc, _ rhs: UICircleArc) -> [Vector2D] {
        let intersection = lhs.asCircle2D.intersection(with: rhs.asCircle2D)
        let points: [PointNormal<Vector2D>]

        switch intersection {
        case .contained, .contains, .noIntersection:
            return []

        case .singlePoint(let pt):
            points = [pt]

        case .pairs(let pts):
            points = pts.flatMap({ [$0.enter, $0.exit] })
        }

        return points.map(\.point)
    }

    fileprivate func intersectionPoints(_ lhs: UICircleArc, _ rhs: PeriodicSurfaceStroke.Op) -> [Vector2D] {
        switch rhs {
        case .line(let rhs):
            return intersectionPoints(lhs, rhs)

        case .circleArc(let rhs):
            return intersectionPoints(lhs, rhs)

        case .compound(let rhs):
            return intersectionPoints(lhs, rhs)
        }
    }

    fileprivate func intersectionPoints(_ lhs: UICircleArc, _ rhs: [PeriodicSurfaceStroke.Op]) -> [Vector2D] {
        var result: [Vector2D] = []

        for rhs in rhs {
            switch rhs {
            case .line(let rhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )

            case .circleArc(let rhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )

            case .compound(let rhs):
                result.append(contentsOf:
                    intersectionPoints(lhs, rhs)
                )
            }
        }

        return result
    }

    fileprivate struct InternalResult {
        var period: Double
        var distance: Double
    }
}
