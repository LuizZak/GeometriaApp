import Geometria
import Geometry

struct PolytopePoly: PolyBooleanType {
    private let _cachedStrokes: PeriodicSurfaceStroke

    var description: String {
        "PolytopePoly(vertices: \(vertices))"
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

    func point(at period: Double) -> Vector {
        return _cachedStrokes
            .compute(at: period)
            .asVector2D
    }

    func stroke(in range: ClosedRange<Double>) -> PeriodicSurfaceStroke {
        let stroke = _cachedStrokes

        guard let stroke = stroke.clipLower(period: range.upperBound) else {
            fatalError("Failed to clip lower bound of polytope")
        }
        guard let stroke = stroke.clipHigher(period: range.lowerBound) else {
            fatalError("Failed to clip upper bound of polytope")
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

    static func allStrokes(vertices: [Vertex]) -> [PeriodicSurfaceStroke] {
        var result: [PeriodicSurfaceStroke] = []

        for (index, vertex) in vertices.enumerated() {
            let nextIndex = (index + 1) % vertices.count
            let next = vertices[nextIndex]
            var end = next.period

            // Make sure we don't incorrectly wrap around the needed 1.0 end
            // period
            if nextIndex == 0 {
                end = 1.0
            }

            let stroke = PeriodicSurfaceStroke(
                start: vertex.period,
                end: end,
                op: .line(.init(start: vertex.position.asUIPoint, end: next.position.asUIPoint))
            )

            result.append(stroke)
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
