/// Represents an N-dimensional rounded rectangle with a rectangle and radius
/// for each axis.
public struct RoundNRectangle<Vector: VectorType>: GeometricType {
    /// Convenience for `Vector.Scalar`
    public typealias Scalar = Vector.Scalar
    
    public var rectangle: NRectangle<Vector>
    public var radius: Vector
    
    public var description: String {
        "\(type(of: self))(rectangle: \(rectangle), radius: \(radius))"
    }
    
    @_transparent
    public init(rectangle: NRectangle<Vector>, radius: Vector) {
        self.rectangle = rectangle
        self.radius = radius
    }
}

extension RoundNRectangle: Equatable where Vector: Equatable { }
extension RoundNRectangle: Hashable where Vector: Hashable { }
extension RoundNRectangle: Encodable where Vector: Encodable { }
extension RoundNRectangle: Decodable where Vector: Decodable { }

extension RoundNRectangle: BoundableType where Vector: VectorAdditive {
    /// Returns the minimal ``AABB`` capable of containing this round rectangle's
    /// bounds.
    @_transparent
    public var bounds: AABB<Vector> {
        rectangle.bounds
    }
}
