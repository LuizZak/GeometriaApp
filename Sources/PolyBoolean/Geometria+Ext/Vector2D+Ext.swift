import Geometria
import Geometry

extension Vector2D {
    var asUIVector: UIVector {
        .init(x: x, y: y)
    }

    var asUIPoint: UIPoint {
        .init(x: x, y: y)
    }
}
