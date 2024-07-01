import Geometria
import Geometry

extension UILine {
    var asLineSegment2D: LineSegment2D {
        .init(start: start.asVector2D, end: end.asVector2D)
    }

    /// Returns the result of `lhs.start + (lhs.end - lhs.start) * rhs`.
    static func * (lhs: Self, rhs: Scalar) -> UIPoint {
        lhs.start + (lhs.end - lhs.start) * rhs
    }

    /// Returns the result of `rhs.start + (rhs.end - rhs.start) * lhs`.
    static func * (lhs: Scalar, rhs: Self) -> UIPoint {
        rhs.start + (rhs.end - rhs.start) * lhs
    }
}
