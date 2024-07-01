import Geometria
import Geometry

extension LineSegment2D {
    var asUILine: UILine {
        .init(start: start.asUIPoint, end: end.asUIPoint)
    }
}
