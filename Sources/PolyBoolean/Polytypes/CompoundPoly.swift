import Geometry

/// A boolean poly boolean type that is represented solely with a compound stroke
/// operation.
struct CompoundPoly: PolyBooleanType {
    var description: String {
        "\(type(of: self))(stroke: \(stroke))"
    }

    private var _cached: UIBezier
    var stroke: PeriodicSurfaceStroke {
        didSet {
            _cached = stroke.asUIBezier()

            _assertValid()
        }
    }

    init(stroke: PeriodicSurfaceStroke) {
        self.stroke = stroke
        self._cached = stroke.asUIBezier()

        _assertValid()
    }

    func contains(_ point: Vector) -> Bool {
        _cached.contains(point.asUIPoint)
    }

    func isOnSurface(_ point: Vector, tolerance: Double) -> Bool {
        _cached.distance(to: point.asUIPoint) < tolerance
    }

    func point(at period: Period) -> Vector {
        stroke.compute(at: period).asVector2D
    }

    func fullStroke() -> PeriodicSurfaceStroke {
        stroke
    }

    func stroke(in range: ClosedRange<Period>) -> PeriodicSurfaceStroke {
        guard let stroke = stroke.clip(range) else {
            fatalError("Failed to clip surface stroke of compound polygon")
        }

        return stroke
    }

    func _assertValid() {
        #if DEBUG

        let dx = 0.01
        let thresholdSquared: Double = 20 * 20
        for d: Double in stride(from: 0.0, through: 1 - dx, by: dx) {
            let d1 = self.point(at: d)
            let d2 = self.point(at: (d + dx).truncatingRemainder(dividingBy: 1))
            let diff = d1.distanceSquared(to: d2)

            guard diff > thresholdSquared else {
                continue
            }

            /*
            assertionFailure(
                "Found period range \(d - dx) to \(d + dx) where output jumped by \(diff.squareRoot()) in distance?"
            )
            */
        }

        #endif
    }
}

extension PeriodicSurfaceStroke {
    func asUIBezier() -> UIBezier {
        var bezier = UIBezier()
        var lastVertex: UIPoint?

        op.apply(to: &bezier, lastVertex: &lastVertex)

        return bezier
    }
}

extension PeriodicSurfaceStroke.Op {
    func apply(to bezier: inout UIBezier, lastVertex: inout UIPoint?) {
        switch self {
        case .line(let line):
            if lastVertex == nil {
                bezier.move(to: line.start)
            }

            bezier.line(to: line.end)

            lastVertex = line.end

        case .circleArc(let arc):
            if lastVertex == nil {
                bezier.move(to: arc.startPoint)
            }

            bezier.arc(to: arc.endPoint, sweepAngle: arc.sweepAngle)

            lastVertex = arc.endPoint

        case .compound(let ops):
            ops.forEach {
                $0.apply(to: &bezier, lastVertex: &lastVertex)
            }
        }
    }
}
