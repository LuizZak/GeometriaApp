import Geometry

/// A compound point source of interest that joins point of interests from mutliple
/// sources.
class CompoundPointOfInterestSource: PointOfInterestSource {
    let sources: [any PointOfInterestSource]

    init(sources: [any PointOfInterestSource]) {
        assert(!sources.isEmpty)

        self.sources = sources
    }

    /// Returns the first non-nil point of interest returned from the point of
    /// interest source this compound POI object was initialized with.
    func firstPointOfInterest(geometryId: Int) -> PointOfInterest? {
        for source in sources {
            if let first = source.firstPointOfInterest(geometryId: geometryId) {
                return first
            }
        }

        return nil
    }

    func nextPointOfInterest(from current: PointOfInterest) -> PointOfInterest {
        let points =
            sources.map {
                $0.nextPointOfInterest(from: current)
            }.sorted {
                $0.period < $1.period
            }

        // Return the earliest point of interest found, wrapping around if no more
        // POIs have been found
        let pointsAfter =
            points.filter {
                $0.period > current.period
            }

        if pointsAfter.isEmpty {
            return points.first ?? current
        }

        return pointsAfter.first ?? current
    }
}
