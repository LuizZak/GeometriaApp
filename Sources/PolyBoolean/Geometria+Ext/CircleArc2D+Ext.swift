import Geometria
import Geometry

extension CircleArc2D {
    var asUICircleArc: UICircleArc {
        .init(
            center: center.asUIPoint,
            radius: radius,
            startAngle: startAngle.radians,
            sweepAngle: sweepAngle.radians
        )
    }
}
