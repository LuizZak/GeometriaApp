import Geometry

class UnionBooleanPOIOperation {
    typealias GeometryId = Int

    init() {

    }

    func union(
        _ lhs: any PolyBooleanType,
        _ rhs: any PolyBooleanType
    ) -> [PeriodicSurfaceStroke] {

        let lhsGeometryId = 0
        let rhsGeometryId = 1

        let intersections = PolyIntersect()._intersect(
            lhs,
            lhsGeometryId: lhsGeometryId,
            rhs,
            rhsGeometryId: rhsGeometryId
        )

        let sources: [any PointOfInterestSource] = [
            GeometryPointOfInterestSource(geometries: [
                lhsGeometryId: lhs.fullStroke(),
                rhsGeometryId: rhs.fullStroke(),
            ]),
            IntersectingPointOfInterestSource(intersections: intersections),
        ]
        let source = CompoundPointOfInterestSource(sources: sources)

        return union(
            lhs,
            lhsGeometryId: lhsGeometryId,
            rhs,
            rhsGeometryId: rhsGeometryId,
            pointOfInterestSource: source
        )
    }

    func union(
        _ lhs: any PolyBooleanType,
        lhsGeometryId: GeometryId,
        _ rhs: any PolyBooleanType,
        rhsGeometryId: GeometryId,
        pointOfInterestSource: any PointOfInterestSource
    ) -> [PeriodicSurfaceStroke] {

        func geom(_ id: GeometryId) -> PeriodicSurfaceStroke {
            if id == lhsGeometryId {
                lhs.fullStroke()
            } else {
                rhs.fullStroke()
            }
        }
        func geom(_ poi: PointOfInterest) -> PeriodicSurfaceStroke {
            geom(poi.geometryId)
        }
        func pointFor(_ poi: PointOfInterest) -> UIPoint {
            switch poi {
            case .geometry:
                return geom(poi).compute(at: poi.period)

            case .intersection(let point, _, _, _, _, _):
                return point
            }
        }

        guard let start = pointOfInterestSource.firstPointOfInterest(geometryId: lhsGeometryId) else {
            return []
        }

        var current = start
        if current.isWithinOtherGeometry {
            current = pointOfInterestSource.nextPointOfInterest(from: current)
        }

        var visited: Set<PointOfInterest> = []
        var idsSeen: Set<GeometryId> = []

        var ops: [PeriodicSurfaceStroke.Op] = []

        var startPoint = pointFor(current)
        var lastKind = current.geometryKind
        while true {
            guard visited.insert(current).inserted else {
                break
            }

            let currentPoint = pointFor(current)

            var next = pointOfInterestSource.nextPointOfInterest(from: current)
            let nextPoint = pointFor(next)

            switch next {
            case .geometry:
                break

            case .intersection(let point, let geometryId, let period, let periodOnOther, let otherGeometry, let otherGeometryId):
                next = .intersection(
                    point,
                    geometryId: otherGeometryId,
                    period: periodOnOther,
                    periodOnOther: period,
                    otherGeometry: lastKind,
                    otherGeometryId: geometryId
                )
            }

            defer {
                current = next
                lastKind = current.geometryKind
            }

            switch lastKind {
            case .line:
                let line = UILine(
                    start: currentPoint,
                    end: nextPoint
                )

                ops.append(.line(line))

            case .circularArc(let center, let sweepAngle):
                var arc = UICircleArc(
                    center: center,
                    startPoint: currentPoint,
                    endPoint: nextPoint
                )
                if arc.sweepAngle <= 0 {
                    arc.sweepAngle = sweepAngle
                }

                ops.append(.circleArc(arc))
            }
        }

        return [
            .init(start: 0, end: 1, op: .compound(ops))
        ]
    }
}
