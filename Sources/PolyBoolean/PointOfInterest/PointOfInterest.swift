import Geometry

/// A point of interest in a poly boolean geometry.
enum PointOfInterest: Hashable {
    /// The end-point of a geometry.
    case geometry(
        GeometryKind,
        geometryId: Int,
        period: Double,
        isWithinOtherGeometry: Bool
    )

    /// A point of intersection against another geometry.
    case intersection(
        UIPoint,
        geometryId: Int,
        period: Double,
        periodOnOther: Double,
        otherGeometry: GeometryKind,
        otherGeometryId: Int
    )

    /// Returns `true` if this is an intersection point of interest.
    var isIntersection: Bool {
        switch self {
        case .geometry: return false
        case .intersection: return true
        }
    }

    /// Gets the main geometry ID associated with this point of interest.
    var geometryId: Int {
        switch self {
        case .geometry(_, let geometryId, _, _),
            .intersection(_, let geometryId, _, _, _, _):
            return geometryId
        }
    }

    /// Gets the period associated with this point of interest.
    var period: Double {
        switch self {
        case .geometry(_, _, let period, _),
            .intersection(_, _, let period, _, _, _):
            return period
        }
    }

    /// Returns `true` whether this point-of-interest represents a geometry point
    /// that is contained within geometry other than the shape it is a part of.
    var isWithinOtherGeometry: Bool {
        switch self {
        case .geometry(_, _, _, let isWithinOtherGeometry):
            return isWithinOtherGeometry

        case .intersection(_, _, _, _, _, _):
            return false
        }
    }

    /// Returns the geometry kind that this point of interest is attached to.
    var geometryKind: GeometryKind {
        switch self {
        case .geometry(let geometryKind, _, _, _),
            .intersection(_, _, _, _, let geometryKind, _):
            return geometryKind
        }
    }

    /// Returns `true` if `lhs` precedes `rhs` in the period of the shape they
    /// represent.
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.geometryId == rhs.geometryId && lhs.period < rhs.period
    }

    /// Specifies the representable kinds of geometry.
    enum GeometryKind: Hashable {
        /// A straight-line geometry.
        case line

        /// A circular arg geometry, with a given center point and sweep angle.
        case circularArc(center: UIPoint, sweepAngle: Double)

        static func fromPeriodicSurfaceStrokeOp(_ op: PeriodicSurfaceStroke.Op) -> Self {
            switch op {
            case .line:
                return .line

            case .circleArc(let arc):
                return .circularArc(center: arc.center, sweepAngle: arc.sweepAngle)

            case .compound(let ops):
                return fromPeriodicSurfaceStrokeOp(ops[0])
            }
        }
    }
}
