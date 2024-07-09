import Geometria
import GeometriaClipping

extension Circle2Parametric {
    init(circle: Circle2D) {
        self.init(circle2: circle, startPeriod: 0.0, endPeriod: 1.0)
    }
}
