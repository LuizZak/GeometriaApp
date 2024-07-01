import Geometria
import Geometry

extension UICircleArc {
    var asEllipse2D: Ellipse2D {
        .init(center: center.asVector2D, radiusX: radius, radiusY: radius)
    }

    var asCircle2D: Circle2D {
        .init(center: center.asVector2D, radius: radius)
    }

    var stopAngle: Scalar {
        startAngle + sweepAngle
    }

    /// Flips the angles of this arc so that `startAngle` and `sweepAngle` occur
    /// in the opposite directions, while still covering the same arc on a circle.
    var mirrored: Self {
        .init(center: center, radius: radius, startAngle: stopAngle, sweepAngle: -sweepAngle)
    }
}
