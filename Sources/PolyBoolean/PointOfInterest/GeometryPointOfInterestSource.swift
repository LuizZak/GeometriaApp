import Geometry

/// A source for points of interest that refer to a geometry's construction.
class GeometryPointOfInterestSource: PointOfInterestSource {
    private var _bezierCache: [GeometryId: UIBezier] = [:]

    typealias Period = Double
    typealias GeometryId = Int

    var geometries: [GeometryId: PeriodicSurfaceStroke]

    init(geometries: [GeometryId: PeriodicSurfaceStroke]) {
        self.geometries = geometries
    }

    func firstPointOfInterest(geometryId: Int) -> PointOfInterest? {
        guard let firstGeom = geometries[geometryId] else {
            return nil
        }

        let point = firstGeom.compute(at: 0.0)
        let op = firstGeom.op.operation(at: 0.0)
        let opKind = PointOfInterest.GeometryKind.fromPeriodicSurfaceStrokeOp(op)

        return PointOfInterest.geometry(
            opKind,
            geometryId: geometryId,
            period: 0.0,
            isWithinOtherGeometry: isWithinOtherGeometry(geometryId, point: point)
        )
    }

    func isWithinOtherGeometry(_ geometryId: Int, point: UIPoint) -> Bool {
        for (id, geometry) in geometries where id != geometryId {
            let bezier = _fetchBezierFor(id, geometry)
            if bezier.contains(point) {
                return true
            }
        }

        return false
    }

    func nextPointOfInterest(
        from current: PointOfInterest
    ) -> PointOfInterest {
        let geometryId = current.geometryId

        guard let geometry = _findGeometry(geometryId) else {
            return current
        }

        let totalLength = geometry.length

        return _nextPoi(
            on: geometry.op,
            period: current.period,
            geometry: geometry,
            geometryId: geometryId,
            startLength: 0,
            totalLength: totalLength
        )
    }

    private func _nextPoi(
        on op: PeriodicSurfaceStroke.Op,
        period: Period,
        geometry: PeriodicSurfaceStroke,
        geometryId: Int,
        startLength: Double,
        totalLength: Double
    ) -> PointOfInterest {

        func periodOfLength(_ len: Double) -> Period {
            let offset = startLength + len

            return (offset / totalLength).truncatingRemainder(dividingBy: 1)
        }
        func withinGeometry(_ point: UIPoint) -> Bool {
            return self.isWithinOtherGeometry(
                geometryId,
                point: point
            )
        }

        switch op {
        case .line(let line):
            let len = line.length()

            return .geometry(
                PointOfInterest.GeometryKind.fromPeriodicSurfaceStrokeOp(op),
                geometryId: geometryId,
                period: periodOfLength(len),
                isWithinOtherGeometry: withinGeometry(line.end)
            )

        case .circleArc(let arc):
            let len = arc.length()

            return .geometry(
                PointOfInterest.GeometryKind.fromPeriodicSurfaceStrokeOp(op),
                geometryId: geometryId,
                period: periodOfLength(len),
                isWithinOtherGeometry: withinGeometry(arc.endPoint)
            )

        case .compound(let inner):
            let flattened = inner.flattenedRelativePeriods()
            for (range, inner) in flattened {
                guard range.lowerBound > period else {
                    continue
                }

                return _nextPoi(
                    on: inner,
                    period: period,
                    geometry: geometry,
                    geometryId: geometryId,
                    startLength: startLength,
                    totalLength: totalLength
                )
            }

            // On fail; loop back to the first geometry
            return _nextPoi(
                on: inner[0],
                period: period,
                geometry: geometry,
                geometryId: geometryId,
                startLength: startLength,
                totalLength: totalLength
            )
        }
    }

    private func _findGeometry(_ geometryId: Int) -> PeriodicSurfaceStroke? {
        geometries[geometryId]
    }

    private func _fetchBezierFor(_ geometryId: Int, _ geometry: PeriodicSurfaceStroke) -> UIBezier {
        if let cached = _bezierCache[geometryId] {
            return cached
        }

        let bezier = geometry.asUIBezier()
        _bezierCache[geometryId] = bezier

        return bezier
    }
}
