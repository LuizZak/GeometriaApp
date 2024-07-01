import Geometria
import Geometry

extension AABB2D {
    var asUIRectangle: UIRectangle {
        .init(minimum: minimum.asUIPoint, maximum: maximum.asUIPoint)
    }
}
