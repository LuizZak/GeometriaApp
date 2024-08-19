import Geometria
import Geometry

extension UIIntSize {
    var asVector2D: Vector2D {
        .init(x: Vector2D.Scalar(width), y: Vector2D.Scalar(height))
    }
}
