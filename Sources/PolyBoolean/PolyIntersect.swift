import Geometria

struct PolyIntersectResult {
    typealias Period = Double

    var periods: [Pair]

    struct Pair {
        var lhsPeriod: Period
        var rhsPeriod: Period
    }
}

class PolyIntersect {
    var maxDistanceThreshold: Double = 0.01

    func intersect(_ lhs: any PolyBooleanType, _ rhs: any PolyBooleanType) -> PolyIntersectResult? {
        return intersect(lhs.stroke(in: 0...1), rhs.stroke(in: 0...1))
    }

    func intersect(_ lhs: RectPoly, _ rhs: CirclePoly) -> PolyIntersectResult {
        return intersect(lhs.stroke(in: 0...1), rhs.stroke(in: 0...1))
    }

    fileprivate func intersect(_ lhs: PeriodicSurfaceStroke, _ rhs: PeriodicSurfaceStroke) -> PolyIntersectResult {
        typealias Period = Double
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

        var result = PolyIntersectResult(periods: [])

        let points = intersectionPoints(lhs, rhs)
        for point in points {
            if
                let lhsPeriod = clipPeriod(point, lhs),
                let rhsPeriod = clipPeriod(point, rhs)
            {
                result.periods.append(
                    .init(lhsPeriod: lhsPeriod, rhsPeriod: rhsPeriod)
                )
            }
        }

        return result
    }

    fileprivate func intersectionPoints(_ lhs: PeriodicSurfaceStroke, _ rhs: PeriodicSurfaceStroke) -> [Vector2D] {
        switch (lhs.op, rhs.op) {
        case (.line(let l), .line(let r)):
            guard let intersection = l.asLineSegment2D.intersection(with: r.asLineSegment2D) else {
                break
            }

            return [intersection.point]

        case (.circleArc(let l), .circleArc(let r)):
            let intersection = l.asCircle2D.intersection(with: r.asCircle2D)
            let points: [PointNormal<Vector2D>]

            switch intersection {
            case .contained, .contains, .noIntersection:
                return []

            case .singlePoint(let pt):
                points = [pt]

            case .points(let pts):
                points = pts
            }

            return points.map(\.point)

        case (.line(let line), .circleArc(let arc)),
            (.circleArc(let arc), .line(let line)):
            let intersection = arc.asCircle2D.intersection(with: line.asLineSegment2D)

            switch intersection {
            case .contained, .noIntersection:
                return []

            case .enter(let pn), .exit(let pn), .singlePoint(let pn):
                return [pn.point]

            case .enterExit(let enter, let exit):
                return [enter.point, exit.point]
            }

        case (.circleArc, .compound(let compound)):
            return intersectionPoints([lhs], compound)

        case (.compound(let compound), .circleArc):
            return intersectionPoints(compound, [rhs])

        case (.compound(let compound), .line):
            return intersectionPoints([lhs], compound)

        case (.line, .compound(let compound)):
            return intersectionPoints(compound, [rhs])

        case (.compound(let lhs), .compound(let rhs)):
            return intersectionPoints(lhs, rhs)
        }

        return []
    }

    fileprivate func intersectionPoints(_ lhs: [PeriodicSurfaceStroke], _ rhs: [PeriodicSurfaceStroke]) -> [Vector2D] {
        var result: [Vector2D] = []

        for lhs in lhs {
            for rhs in rhs {
                let points = intersectionPoints(lhs, rhs)
                result.append(contentsOf: points)
            }
        }

        return result
    }

    fileprivate struct InternalResult {
        var period: Double
        var distance: Double
    }
}
