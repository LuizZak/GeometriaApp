import Geometria

/// A Union boolean parametric that joins two shapes into a single shape, if they
/// intersect in space.
public struct Intersection2Parametric: Boolean2Parametric {
    public typealias Period = Double
    public let lhs: T1, rhs: T2
    public let tolerance: Scalar

    public init(_ lhs: T1, _ rhs: T2, tolerance: T1.Scalar) {
        self.lhs = lhs
        self.rhs = rhs
        self.tolerance = tolerance
    }

    public func allContours() -> [Contour] {
        typealias State = GeometriaClipping.State

        let lhsContours = lhs.allContours()
        let rhsContours = rhs.allContours()

        let lookup: IntersectionLookup = .init(
            lhsShapes: lhsContours,
            lhsRange: lhs.startPeriod..<lhs.endPeriod,
            rhsShapes: rhsContours,
            rhsRange: rhs.startPeriod..<rhs.endPeriod,
            tolerance: tolerance
        )

        let resultOverall = ContourManager()

        // Re-combine the contours by working from bottom-to-top, stopping at
        // contours that participate in intersections, adding the contours on top
        // of the result
        for index in 0..<lhsContours.count {
            if !lookup.hasIntersections(lhsIndex: index) {
                if lookup.isInside(lhsContours[index], rhsContours) {
                    resultOverall.append(lhsContours[index])
                }
            }
        }
        for index in 0..<rhsContours.count {
            if !lookup.hasIntersections(rhsIndex: index) {
                if lookup.isInside(rhsContours[index], lhsContours) {
                    resultOverall.append(lhsContours[index])
                }
            }
        }

        // For intersections, we need to visit every possible corner of lhs, so
        // we keep track of simplexes visited overall during production, as well
        // as continually produce simplexes for the isolated segments that need
        // to be built
        var simplexVisited: Set<State> = []
        var visitedOverall: Set<State> = []

        guard var state = lookup.candidateStart()?.flipped() else {
            return resultOverall.allContours()
        }

        while visitedOverall.insert(state).inserted {
            if !simplexVisited.contains(state) {
                let result = resultOverall.beginContour()
                var visited: Set<State> = []

                while visited.insert(state).inserted {
                    // Find next intersection
                    let next = lookup.next(state)

                    // Append simplex
                    let simplex = lookup.clampedSimplexesRange(state, next)
                    result.append(contentsOf: simplex)

                    // Flip to the next intersection
                    state = next.flipped()
                }

                simplexVisited.formUnion(visited)

                // Re-normalize the simplex periods
                result.endContour(startPeriod: .zero, endPeriod: 1)
            }

            // Here we skip twice in order to skip the portion of lhs that is
            // occluded behind rhs, and land on the next intersection that brings
            // lhs inside rhs
            state = lookup.next(lookup.next(state))
        }

        return resultOverall.allContours()
    }
}
