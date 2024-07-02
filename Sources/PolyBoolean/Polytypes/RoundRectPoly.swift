import Foundation
import Geometry
import Geometria

struct RoundedRectPoly: PolyBooleanType {
    var description: String {
        "\(type(of: self))(inner: \(inner))"
    }

    private var inner: PeriodicSurfaceStroke
    private var asUIRoundRectangle: UIRoundRectangle {
        .init(rectangle: aabb.asUIRectangle, radiusX: radius, radiusY: radius)
    }

    var aabb: AABB2D {
        didSet {
            _recreate()
        }
    }
    var radius: Double {
        didSet {
            _recreate()
        }
    }

    init(aabb: AABB2D, radius: Double) {
        self.aabb = aabb
        self.radius = radius
        self.inner = Self.allStrokesCombined(aabb, radius)
    }

    init(location: Vector2D, size: Vector2D, radius: Double) {
        self.init(
            aabb: .init(location: location, size: size),
            radius: radius
        )
    }

    private mutating func _recreate() {
        inner = Self.allStrokesCombined(aabb, radius)
    }

    func point(at period: Double) -> Vector {
        return inner
            .compute(at: period)
            .asVector2D
    }

    func contains(_ point: Vector2D) -> Bool {
        asUIRoundRectangle.contains(point.asUIPoint)
    }

    func stroke(in range: ClosedRange<Double>) -> PeriodicSurfaceStroke {
        let stroke = inner

        guard let stroke = stroke.clipLower(period: range.upperBound) else {
            fatalError("Failed to clip lower bound of polytope")
        }
        guard let stroke = stroke.clipHigher(period: range.lowerBound) else {
            fatalError("Failed to clip upper bound of polytope")
        }

        return stroke
    }

    static func allStrokesCombined(_ aabb: AABB2D, _ radius: Double) -> PeriodicSurfaceStroke {
        .init(
            start: 0,
            end: 1.0,
            op: .compound(
                allStrokes(aabb, radius)
            )
        )
    }

    static func allStrokes(_ aabb: AABB2D, _ radius: Double) -> [PeriodicSurfaceStroke] {
        var result: [PeriodicSurfaceStroke] = []

        func add(_ op: PeriodicSurfaceStroke.Op) {
            let stroke = PeriodicSurfaceStroke(
                start: 0.0,
                end: 0.0,
                op: op
            )

            result.append(stroke)
        }

        let leftTop = UIPoint(x: aabb.left, y: aabb.top + radius)
        let leftBottom = UIPoint(x: aabb.left, y: aabb.bottom - radius)
        let topLeft = UIPoint(x: aabb.left + radius, y: aabb.top)
        let topRight = UIPoint(x: aabb.right - radius, y: aabb.top)
        let rightTop = UIPoint(x: aabb.right, y: aabb.top + radius)
        let rightBottom = UIPoint(x: aabb.right, y: aabb.bottom - radius)
        let bottomRight = UIPoint(x: aabb.right - radius, y: aabb.bottom)
        let bottomLeft = UIPoint(x: aabb.left + radius, y: aabb.bottom)

        let arcTopLeft = UICircleArc(
            center: aabb.topLeft.asUIPoint + radius,
            radius: radius,
            startAngle: .pi,
            sweepAngle: .pi / 2
        )
        let arcTopRight = UICircleArc(
            center: aabb.topRight.asUIPoint + .init(x: -radius, y: radius),
            radius: radius,
            startAngle: .pi * 3 / 2,
            sweepAngle: .pi / 2
        )
        let arcBottomRight = UICircleArc(
            center: aabb.bottomRight.asUIPoint - radius,
            radius: radius,
            startAngle: 0,
            sweepAngle: .pi / 2
        )
        let arcBottomLeft = UICircleArc(
            center: aabb.bottomLeft.asUIPoint + .init(x: radius, y: -radius),
            radius: radius,
            startAngle: .pi / 2,
            sweepAngle: .pi / 2
        )

        add(.line(.init(start: topLeft, end: topRight)))
        add(.circleArc(arcTopRight))
        //
        add(.line(.init(start: rightTop, end: rightBottom)))
        add(.circleArc(arcBottomRight))
        //
        add(.line(.init(start: bottomRight, end: bottomLeft)))
        add(.circleArc(arcBottomLeft))
        //
        add(.line(.init(start: leftBottom, end: leftTop)))
        add(.circleArc(arcTopLeft))

        for i in 0..<result.count {
            result[i].start = Double(i) / Double(result.count)
            result[i].end = Double(i + 1) / Double(result.count)
        }
        return result
    }
}
