import Foundation
import Geometry
import Geometria

struct RectPoly: PolyBooleanType {
    var description: String {
        "\(type(of: self))(inner: \(inner))"
    }

    private var inner: PolytopePoly = .init(vertices: [])
    var aabb: AABB2D {
        didSet {
            _recreate()
        }
    }

    init(aabb: AABB2D) {
        self.aabb = aabb
        _recreate()
    }

    init(location: Vector2D, size: Vector2D) {
        self.init(aabb: .init(location: location, size: size))
    }

    private mutating func _recreate() {
        inner = .fromVectors(aabb.corners)
    }

    func contains(_ point: Vector2D) -> Bool {
        inner.contains(point)
    }

    func isOnSurface(_ point: Vector, tolerance: Double) -> Bool {
        inner.isOnSurface(point, tolerance: tolerance)
    }

    func point(at period: Double) -> Vector2D {
        inner.point(at: period)
    }

    func stroke(in range: ClosedRange<Double>) -> PeriodicSurfaceStroke {
        inner.stroke(in: range)
    }
}
