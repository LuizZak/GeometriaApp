import Geometria
import Geometry

extension Ellipse2D {
    var asUIEllipse: UIEllipse {
        .init(center: center.asUIPoint, radius: radius.asUIVector)
    }
}
