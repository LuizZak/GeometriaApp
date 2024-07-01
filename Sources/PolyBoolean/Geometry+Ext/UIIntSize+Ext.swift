import Geometria
import Geometry

extension UIIntSize {
    var asVector2D: Vector2D {
        .init(x: Vector2.Scalar(width), y: Vector2.Scalar(height))
    }
}
