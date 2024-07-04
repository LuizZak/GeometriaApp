import Foundation
import Geometry
import Geometria

struct CirclePoly: PolyBooleanType {
    var description: String {
        "\(type(of: self))(circle: \(circle))"
    }

    var circle: Circle2D

    var asUICircle: UICircle {
        UICircle(center: circle.center.asUIPoint, radius: circle.radius)
    }

    func periodAsAngle(_ period: Double) -> Double {
        period * .pi * 2
    }

    func contains(_ point: Vector2D) -> Bool {
        circle.contains(point)
    }

    func isOnSurface(_ point: Vector, tolerance: Double) -> Bool {
        let distanceSquared = point.distanceSquared(to: circle.center)
        let delta = (distanceSquared - (circle.radius * circle.radius)).magnitude

        return delta <= tolerance
    }

    func point(at period: Double) -> Vector2D {
        let angle = periodAsAngle(period)

        return asUICircle.pointOnAngle(angle).asVector2D
    }

    func stroke(in range: ClosedRange<Double>) -> PeriodicSurfaceStroke {
        let start = periodAsAngle(range.lowerBound)
        let end = periodAsAngle(range.upperBound)

        let arc = asUICircle.arc(start: start, sweep: end)

        return .init(start: range.lowerBound, end: range.upperBound, op: .circleArc(arc))
    }
}
