import Geometria
import Geometry

struct PolytopePoly: PolyBooleanType {
    private let _cachedStrokes: PeriodicSurfaceStroke

    var description: String {
        "\(type(of: self))(vertices: \(vertices))"
    }

    let vertices: [Vertex]
    var asLinePolygon2D: LinePolygon2D {
        LinePolygon2D(vertices: vertices.map(\.position))
    }

    init(vertices: [PolytopePoly.Vertex]) {
        self._cachedStrokes = Self.allStrokesCombined(vertices: vertices)
        self.vertices = vertices
    }

    func contains(_ point: Vector) -> Bool {
        return asLinePolygon2D.contains(point)
    }

    func isOnSurface(_ point: Vector, tolerance: Double) -> Bool {
        return asLinePolygon2D.isPointOnEdge(
            point,
            tolerance: tolerance
        )
    }

    func point(at period: Double) -> Vector {
        return _cachedStrokes
            .compute(at: period)
            .asVector2D
    }

    func stroke(in range: ClosedRange<Double>) -> PeriodicSurfaceStroke {
        guard let stroke = _cachedStrokes.clip(range) else {
            fatalError("Failed to clip stroke surface of polytope")
        }

        return stroke
    }

    private func line(start: Period, end: Period) -> UILine {
        .init(start: point(at: start).asUIPoint, end: point(at: end).asUIPoint)
    }

    static func allStrokesCombined(vertices: [Vertex]) -> PeriodicSurfaceStroke {
        .init(
            start: 0,
            end: 1.0,
            op: .compound(
                allStrokes(vertices: vertices)
            )
        )
    }

    static func allStrokes(vertices: [Vertex]) -> [PeriodicSurfaceStroke.Op] {
        var result: [PeriodicSurfaceStroke.Op] = []

        for (index, vertex) in vertices.enumerated() {
            let nextIndex = (index + 1) % vertices.count
            let next = vertices[nextIndex]

            result.append(
                .line(.init(start: vertex.position.asUIPoint, end: next.position.asUIPoint))
            )
        }

        return result
    }

    static func fromVectors(_ vectors: some Sequence<Vector2D>) -> Self {
        var vertices = vectors.map {
            Vertex.init(period: 0, position: $0)
        }

        for i in 0..<vertices.count {
            vertices[i].period = Double(i) / Double(vertices.count)
        }

        return .init(vertices: vertices)
    }

    struct Vertex {
        var period: Double
        var position: Vector2D
    }
}
