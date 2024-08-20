import Foundation
import ImagineUI
import Geometria
import GeometriaClipping

class PolyBooleanScene {
    var strokeAnimation: Double = 0.0
    var isMouseDown: Bool = false
    var mouseLocation: UIPoint = .zero
    var size: UIIntSize = .zero

    required init() {

    }

    func initialize(size: UIIntSize) {
        strokeAnimation = 0.0
        self.size = size
    }

    func resize(_ size: UIIntSize) {
        self.size = size
    }

    func update(_ delta: TimeInterval) {
        strokeAnimation = (strokeAnimation + delta).clamp(min: 0.0, max: 1.0)
    }

    func render(in renderer: any Renderer, clipRegion: any ClipRegionType) {
        renderer.setStroke(
            .init(color: .black, width: 3, startCap: .round, endCap: .round, joinStyle: .round)
        )
    }

    func mouseDown(_ event: MouseEventArgs) {
        mouseLocation = event.location
        isMouseDown = true
    }
    func mouseMove(_ event: MouseEventArgs) {
        mouseLocation = event.location
    }
    func mouseUp(_ event: MouseEventArgs) {
        mouseLocation = event.location
        isMouseDown = false
    }

    func renderUnion(
        polys: [any ParametricClip2Geometry<Vector2D>],
        tolerance: Double = 1e-14,
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }

        let base = union(tolerance: tolerance, contours: polys.flatMap { $0.allContours() })

        render(poly: base, renderer: renderer)
    }

    func renderSubtraction(
        polys: [any ParametricClip2Geometry<Vector2D>],
        tolerance: Double = 1e-12,
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }
        let compounds = polys.map({ Compound2Parametric(contours: $0.allContours()) })

        guard let first = compounds.first else {
            return
        }

        let base = subtraction(
            tolerance: tolerance,
            first,
            Array(compounds.dropFirst())
        )

        render(poly: base, renderer: renderer)
    }

    func renderXor(
        polys: [any ParametricClip2Geometry<Vector2D>],
        tolerance: Double = 1e-12,
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }

        let base = exclusiveDisjunction(tolerance: tolerance, contours: polys.flatMap { $0.allContours() })

        render(poly: base, renderer: renderer)
    }

    func renderIntersection(
        polys: [any ParametricClip2Geometry<Vector2D>],
        tolerance: Double = 1e-12,
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }

        let base = intersection(tolerance: tolerance, contours: polys.flatMap { $0.allContours() })

        render(poly: base, renderer: renderer)
    }

    func render(polys: [any ParametricClip2Geometry<Vector2D>], renderer: any Renderer) {
        for poly in polys {
            render(poly: poly, renderer: renderer)
        }
    }

    func render<Polygon: ParametricClip2Geometry<Vector2D>>(poly: Polygon, renderer: any Renderer) {
        for contour in poly.allContours() {
            render(contour: contour, renderer: renderer)
        }
    }

    func render(contour: Parametric2Contour<Vector2D>, renderer: any Renderer) {
        let simplexes = contour.clampedSimplexes(in: 0..<strokeAnimation)
        let actual = contour.compute(at: strokeAnimation).asUIPoint

        render(ops: simplexes, renderer: renderer)
        renderPoint(actual, color: .green, renderer: renderer)
    }

    func render(ops: [Parametric2GeometrySimplex<Vector2D>], renderer: any Renderer) {
        for op in ops {
            render(op: op, renderer: renderer)
        }
    }

    func render(op: Parametric2GeometrySimplex<Vector2D>, renderer: any Renderer) {
        switch op {
        case .lineSegment2(let lineSegment2):
            render(op: lineSegment2, renderer: renderer)

        case .circleArc2(let circleArc2):
            render(op: circleArc2, renderer: renderer)
        }
    }

    func render(op: LineSegment2Simplex<Vector2D>, renderer: any Renderer) {
        let line = op.lineSegment.asUILine

        renderer.stroke(line)
    }

    func render(op: CircleArc2Simplex<Vector2D>, renderer: any Renderer) {
        let arc = op.circleArc.asUICircleArc

        renderer.stroke(arc)
    }

    func renderPoint(_ point: UIPoint, color: Color, renderer: any Renderer) {
        let circle = UICircle(center: point, radius: 5)
        renderer.setFill(color)
        renderer.fill(circle)
    }

    struct DemoCircle {
        var circle: Circle2Parametric<Vector2D>
        var velocity: Vector2D

        var bounds: AABB2D {
            circle.bounds
        }

        func makeHollow() -> Compound2Parametric<Vector2D> {
            var inner = circle.reversed()
            inner.circle2.radius *= 0.8

            return Compound2Parametric<Vector2D>(contours:
                circle.allContours() + inner.allContours()
            )
        }

        func updating(_ dt: TimeInterval, bounds: AABB2D) -> Self {
            var copy = self
            copy.update(dt, bounds: bounds)
            return copy
        }

        mutating func update(_ dt: TimeInterval, bounds: AABB2D) {
            // Make sure we can travel before updating the positions
            guard circle.circle2.radius < bounds.width && circle.circle2.radius < bounds.height else {
                return
            }

            circle.circle2.center += velocity * dt
            let circleBounds = circle.circle2.bounds

            if circleBounds.left <= bounds.minimum.x {
                velocity.x = velocity.x.magnitude
            } else if circleBounds.right >= bounds.maximum.x {
                velocity.x = -(velocity.x.magnitude)
            }
            if circleBounds.top < bounds.minimum.y {
                velocity.y = velocity.y.magnitude
            } else if circleBounds.bottom >= bounds.maximum.y {
                velocity.y = -(velocity.y.magnitude)
            }
        }
    }
}
