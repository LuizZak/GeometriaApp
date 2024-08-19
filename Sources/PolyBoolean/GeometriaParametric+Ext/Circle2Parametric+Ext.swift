import Geometria
import GeometriaClipping

extension Circle2Parametric where Vector == Vector2D {
    init(circle: Circle2D) {
        self.init(circle2: circle, startPeriod: 0.0, endPeriod: 1.0)
    }
}
