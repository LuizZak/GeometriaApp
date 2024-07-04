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
    var asUICircleArc: UICircleArc {
        asUICircle.arc(start: 0, sweep: .pi * 2)
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
        strokeSurface()
            .compute(at: period)
            .asVector2D
    }

    func fullStroke() -> PeriodicSurfaceStroke {
        strokeSurface()
    }

    func stroke(in range: ClosedRange<Double>) -> PeriodicSurfaceStroke {
        guard let stroke = strokeSurface().clip(range) else {
            fatalError("Failed to clip stroke surface of circle")
        }

        return stroke
    }

    func strokeSurface() -> PeriodicSurfaceStroke {
        let circle = asUICircle

        return .init(
            start: 0,
            end: 1,
            op: .compound([
                .circleArc(circle.arc(start: 0, sweep: .pi / 2)),
                .circleArc(circle.arc(start: .pi / 2, sweep: .pi / 2)),
                .circleArc(circle.arc(start: .pi, sweep: .pi / 2)),
                .circleArc(circle.arc(start: .pi * 3 / 2, sweep: .pi / 2)),
            ])
        )
    }
}
