import Geometria
import Geometry

/// Performs Union boolean operations on `PolyBooleanType` instances.
enum UnionBooleanOperation {
    static func union<T1: PolyBooleanType, T2: PolyBooleanType>(
        _ lhs: T1,
        _ rhs: T2
    ) -> [PeriodicSurfaceStroke] where T1.Period == T2.Period {
        _union(lhs, rhs)
    }

    static func _union(_ lhs: any PolyBooleanType, _ rhs: any PolyBooleanType) -> [PeriodicSurfaceStroke] {
        typealias Period = Double

        let intersect = PolyIntersect()
        let intersections = intersect.intersect(lhs, rhs)

        if intersections.isEmpty {
            // If one of the shapes contains the other, and no intersections have
            // been reported, return the stroke surface of the shape that contains
            // the other
            if lhs.contains(rhs.point(at: 0.0)) {
                return [lhs.fullStroke()]
            }
            if rhs.contains(lhs.point(at: 0.0)) {
                return [rhs.fullStroke()]
            }

            // No intersections - result are the input surfaces.
            return [
                lhs.fullStroke(),
                rhs.fullStroke()
            ]
        }

        let lookup = IntersectionLookup(
            shape1: lhs,
            shape2: rhs,
            intersections
        )

        var strokes: [PeriodicSurfaceStroke.Op] = []

        var state = State.onLhs(lhsPeriod: 0.0, rhsPeriod: 0.0)
        if lookup.isWithinShape2(0.0) {
            guard let next = lookup.nextOnShape1(from: 0.0) else {
                return []
            }

            state = .onLhs(lhsPeriod: next.shape1, rhsPeriod: next.shape2)
        } else {
            guard let prev = lookup.prevOnShape1(from: 0.0) else {
                return []
            }

            state = .onLhs(lhsPeriod: prev.shape1, rhsPeriod: prev.shape2)
        }
        var visited: Set<State> = []

        while let next = state.next(on: lookup) {
            guard visited.insert(state).inserted else {
                break
            }

            let stroke = state.stroke(end: next, onLhs: lhs, rhs: rhs)
            strokes.append(stroke)

            #if DEBUG

            strokes._assertIsConnected()

            #endif

            // Flip to the other shape
            state = next.flipped()
        }

        return [
            .init(start: 0, end: 1, op: .compound(strokes))
        ]
    }

    fileprivate enum State: Hashable {
        typealias Period = Double

        case onLhs(lhsPeriod: Period, rhsPeriod: Period)
        case onRhs(lhsPeriod: Period, rhsPeriod: Period)

        var isLhs: Bool {
            switch self {
            case .onLhs: true
            case .onRhs: false
            }
        }

        var lhsPeriod: Period {
            switch self {
            case .onLhs(let lhsPeriod, _), .onRhs(let lhsPeriod, _):
                return lhsPeriod
            }
        }

        var rhsPeriod: Period {
            switch self {
            case .onLhs(_, let rhsPeriod), .onRhs(_, let rhsPeriod):
                return rhsPeriod
            }
        }

        func strokeRanges(end next: Self) -> [ClosedRange<Period>] {
            let start: Period
            let end: Period

            switch self {
            case .onLhs(let lhsPeriod, _):
                start = lhsPeriod
                end = next.lhsPeriod

            case .onRhs(_, let rhsPeriod):
                start = rhsPeriod
                end = next.rhsPeriod
            }

            if start > end {
                if end == 0 {
                    return [start...1]
                }

                return [
                    start...1,
                    0...end
                ]
            }

            return [start...end]
        }

        func stroke(
            end next: Self,
            onLhs lhs: PolyBooleanType,
            rhs: PolyBooleanType
        ) -> PeriodicSurfaceStroke.Op {

            let shape = isLhs ? lhs : rhs

            let ranges = strokeRanges(end: next)
            if ranges.count == 1 {
                return shape.stroke(in: ranges[0]).op
            }

            return .compound(ranges.map({
                shape.stroke(in: $0).op
            }))
        }

        mutating func flip() {
            switch self {
            case .onLhs(let lhsPeriod, let rhsPeriod):
                self = .onRhs(lhsPeriod: lhsPeriod, rhsPeriod: rhsPeriod)

            case .onRhs(let lhsPeriod, let rhsPeriod):
                self = .onLhs(lhsPeriod: lhsPeriod, rhsPeriod: rhsPeriod)
            }
        }

        func flipped() -> Self {
            switch self {
            case .onLhs(let lhsPeriod, let rhsPeriod):
                return .onRhs(lhsPeriod: lhsPeriod, rhsPeriod: rhsPeriod)

            case .onRhs(let lhsPeriod, let rhsPeriod):
                return .onLhs(lhsPeriod: lhsPeriod, rhsPeriod: rhsPeriod)
            }
        }

        func next(on lookup: IntersectionLookup) -> Self? {
            switch self {
            case .onLhs(let period, _):
                return lookup
                    .nextOnShape1(from: period)
                    .map(Self.onLhs)

            case .onRhs(_, let period):
                return lookup
                    .nextOnShape2(from: period)
                    .map(Self.onRhs)
            }
        }

        func overlaps(_ other: Self) -> Bool {
            let prev: Period
            let next: Period

            switch (self, other) {
            case (.onLhs(let lhs, _), .onLhs(let rhs, _)):
                (prev, next) = (lhs, rhs)

            case (.onRhs(_, let lhs), .onRhs(_, let rhs)):
                (prev, next) = (lhs, rhs)

            default:
                return false
            }

            return prev >= next
        }
    }

    /// A collection of period ranges, starting with `0...1`, and sequentially
    /// subtracted until no non-empty ranges remain.
    fileprivate struct RemainingPeriodRanges {
        typealias Period = Double

        private(set) var ranges: [ClosedRange<Period>]

        var isEmpty: Bool {
            if ranges.isEmpty {
                return true
            }

            return false
        }

        init() {
            ranges = [0...1]
        }

        init(_ value: any PolyBooleanType) {
            ranges = [0...1]
        }

        mutating func subtract(_ range: ClosedRange<Period>) {
            ranges.subtract(range)
        }
    }
}

struct IntersectionLookup {
    typealias Period = PolyBooleanType.Period

    let shape1: any PolyBooleanType
    let shape2: any PolyBooleanType

    let shape1Periods: [Period]
    let shape2Periods: [Period]

    init(
        shape1: any PolyBooleanType,
        shape2: any PolyBooleanType,
        shape1Periods: [Period],
        shape2Periods: [Period]
    ) {
        self.shape1 = shape1
        self.shape2 = shape2
        self.shape1Periods = shape1Periods.sorted()
        self.shape2Periods = shape2Periods.sorted()
    }

    init(
        shape1: any PolyBooleanType,
        shape2: any PolyBooleanType,
        _ intersectResult: PolyIntersectResult
    ) {
        self.shape1 = shape1
        self.shape2 = shape2

        let lhsPeriods = intersectResult.pairs.map(\.lhs).flatMap { [$0.start, $0.end] }.sorted()
        let rhsPeriods = intersectResult.pairs.map(\.rhs).flatMap { [$0.start, $0.end] }.sorted()

        self.shape1Periods = lhsPeriods
        self.shape2Periods = rhsPeriods
    }

    func isWithinShape2(_ shape1Period: Period) -> Bool {
        let point = shape1.point(at: shape1Period)

        return shape2.contains(point)
    }

    func isWithinShape1(_ shape2Period: Period) -> Bool {
        let point = shape2.point(at: shape2Period)

        return shape1.contains(point)
    }

    func isLastInShape1(_ shape1Period: Period) -> Bool {
        _findNextIndex(shape1Period, shape1Periods) == nil
    }

    func isLastInShape2(_ shape2Period: Period) -> Bool {
        _findNextIndex(shape2Period, shape2Periods) == nil
    }

    func nextOnShape1(from period: Period) -> (shape1: Period, shape2: Period)? {
        guard let index = _findNextIndex(period, shape1Periods) else {
            return nil
        }
        let period = shape1Periods[index]

        let onShape2 = _findMatchingIndex(
            shape: shape1,
            periodOnShape: period,
            otherShape: shape2,
            otherShapePeriods: shape2Periods
        )

        return (period, onShape2)
    }

    func prevOnShape1(from period: Period) -> (shape1: Period, shape2: Period)? {
        guard let index = _findPrevIndex(period, shape1Periods) else {
            return nil
        }
        let period = shape1Periods[index]

        let onShape2 = _findMatchingIndex(
            shape: shape1,
            periodOnShape: period,
            otherShape: shape2,
            otherShapePeriods: shape2Periods
        )

        return (period, onShape2)
    }

    func nextOnShape2(from period: Period) -> (shape1: Period, shape2: Period)? {
        guard let index = _findNextIndex(period, shape2Periods) else {
            return nil
        }
        let period = shape2Periods[index]

        let onShape1 = _findMatchingIndex(
            shape: shape2,
            periodOnShape: period,
            otherShape: shape1,
            otherShapePeriods: shape1Periods
        )

        return (onShape1, period)
    }

    func prevOnShape2(from period: Period) -> (shape1: Period, shape2: Period)? {
        guard let index = _findPrevIndex(period, shape2Periods) else {
            return nil
        }
        let period = shape2Periods[index]

        let onShape1 = _findMatchingIndex(
            shape: shape2,
            periodOnShape: period,
            otherShape: shape1,
            otherShapePeriods: shape1Periods
        )

        return (onShape1, period)
    }

    private func _findNextIndex(
        _ period: Period,
        _ list: [Period]
    ) -> Int? {
        list.firstIndex(where: { $0 > period }) ?? list.indices.first
    }

    private func _findPrevIndex(
        _ period: Period,
        _ list: [Period]
    ) -> Int? {
        list.lastIndex(where: { $0 < period }) ?? list.indices.last
    }

    private func _findMatchingIndex(
        shape: PolyBooleanType,
        periodOnShape: Period,
        otherShape: PolyBooleanType,
        otherShapePeriods: [Period]
    ) -> Period {
        let pointOnShape = shape.point(at: periodOnShape)

        var closest: (period: Period, distanceSquared: Double) = (0, .infinity)
        for period in otherShapePeriods {
            let point = otherShape.point(at: period)
            let result = (period, distanceSquared: point.distanceSquared(to: pointOnShape))

            if result.distanceSquared < closest.distanceSquared {
                closest = result
            }
        }

        assert(
            closest.distanceSquared < 1e-1,
            "Failed to find close matching intersection in other shape?"
        )

        return closest.period
    }
}
