import Geometria
import Geometry

extension LinePolygon2D {
    var asUIPolygon: UIPolygon {
        .init(vertices: self.vertices.map(\.asUIPoint))
    }
}
