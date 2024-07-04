import Geometry

/// Protocol for types that provide point-of-interest sources.
protocol PointOfInterestSource {
    /// Returns the first valid point of interest for a given geometry in this
    /// point of interest source.
    func firstPointOfInterest(geometryId: Int) -> PointOfInterest?

    /// Gets the next point of interest from the given point on.
    func nextPointOfInterest(from current: PointOfInterest) -> PointOfInterest
}
