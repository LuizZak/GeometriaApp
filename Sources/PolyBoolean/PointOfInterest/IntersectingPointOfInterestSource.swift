import Geometry

/// A source for points of interest that include intersection points between
/// geometry.
class IntersectingPointOfInterestSource: PointOfInterestSource {
    typealias GeometryId = Int
    typealias Period = Double

    let intersections: [Intersection]

    init(intersections: [Intersection]) {
        self.intersections = intersections
    }

    func firstPointOfInterest(geometryId: Int) -> PointOfInterest? {
        guard let intersection = intersections.first(where: { $0.geometry1 == geometryId || $0.geometry2 == geometryId }) else {
            return nil
        }

        return PointOfInterest.intersection(
            intersection.point,
            geometryId: intersection.geometry1,
            period: intersection.geometry1Period,
            periodOnOther: intersection.geometry2Period,
            otherGeometry: intersection.geometry2Kind,
            otherGeometryId: intersection.geometry2
        )
    }

    func nextPointOfInterest(
        from current: PointOfInterest
    ) -> PointOfInterest {

        let geometryId = current.geometryId
        let period = current.period

        guard let intersection = _findNextIntersection(geometryId, period: period) else {
            return current
        }

        if intersection.geometry1 == geometryId {
            return PointOfInterest.intersection(
                intersection.point,
                geometryId: intersection.geometry1,
                period: intersection.geometry1Period,
                periodOnOther: intersection.geometry2Period,
                otherGeometry: intersection.geometry2Kind,
                otherGeometryId: intersection.geometry2
            )
        } else {
            return PointOfInterest.intersection(
                intersection.point,
                geometryId: intersection.geometry2,
                period: intersection.geometry2Period,
                periodOnOther: intersection.geometry1Period,
                otherGeometry: intersection.geometry1Kind,
                otherGeometryId: intersection.geometry1
            )
        }
    }

    private func _findNextIntersection(
        _ geometryId: Int,
        period: Period
    ) -> Intersection? {

        let filtered: [(Intersection, Period)] = intersections
            .compactMap { intersection in
                if intersection.geometry1 == geometryId {
                    (intersection, intersection.geometry1Period)
                } else if intersection.geometry2 == geometryId {
                    (intersection, intersection.geometry2Period)
                } else {
                    nil
                }
            }.sorted(by: { $0.1 < $1.1 })

        if let intersection = filtered.first(where: { $0.1 > period }) {
            return intersection.0
        }

        return filtered.first?.0
    }

    struct Intersection {
        var point: UIPoint

        var geometry1: GeometryId
        var geometry1Period: Period
        var geometry1Kind: PointOfInterest.GeometryKind

        var geometry2: GeometryId
        var geometry2Period: Period
        var geometry2Kind: PointOfInterest.GeometryKind
    }
}
