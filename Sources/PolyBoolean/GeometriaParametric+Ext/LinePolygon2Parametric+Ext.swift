import Geometria
import GeometriaClipping

extension LinePolygon2Parametric {
    init(polygon: LinePolygon2<Vector2D>) {
        self.init(linePolygon2: polygon, startPeriod: 0.0, endPeriod: 1.0)
    }

    init(location: Vector2D, size: Vector2D) {
        let polygon = AABB2D(location: location, size: size)

        self.init(polygon: polygon.asLinePolygon2)
    }
}
