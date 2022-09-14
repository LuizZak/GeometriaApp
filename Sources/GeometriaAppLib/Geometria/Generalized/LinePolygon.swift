/// Represents a line polygon as a series of connected N-dimensional vertices.
///
/// A 2-dimensional line polygon defines a closed polygon, while in higher
/// dimensions it is simply a list of line segments where the ends meet at the
/// vertices.
public struct LinePolygon<Vector: VectorType>: GeometricType {
    public typealias Scalar = Vector.Scalar
    
    /// A sequence of vertices that describe sequential lines connected at the
    /// end points.
    public var vertices: [Vector]
    
    public var description: String {
        "\(type(of: self))(vertices: \(vertices))"
    }
    
    /// Initializes a LinePolygon with empty ``vertices`` list.
    @_transparent
    public init() {
        vertices = []
    }
    
    @_transparent
    public init(vertices: [Vector]) {
        self.vertices = vertices
    }
    
    /// Adds a new vertex at the end of this polygon's ``vertices`` list.
    @_transparent
    public mutating func addVertex(_ v: Vector) {
        vertices.append(v)
    }
}

extension LinePolygon: Equatable where Vector: Equatable { }
extension LinePolygon: Hashable where Vector: Hashable { }
extension LinePolygon: Encodable where Vector: Encodable { }
extension LinePolygon: Decodable where Vector: Decodable { }

extension LinePolygon: BoundableType where Vector: VectorAdditive & VectorComparable {
    /// Returns the minimal ``AABB`` capable of containing all points from this
    /// line polygon.
    ///
    /// If ``vertices`` is empty, a zero AABB is returned, instead.
    @inlinable
    public var bounds: AABB<Vector> {
        AABB(points: vertices)
    }
}

public extension LinePolygon where Vector: VectorFloatingPoint {
    /// Returns a vector with the coordinates of the [arithmetic mean] of all
    /// vectors in ``vertices``.
    ///
    /// If the vertices array is empty, `Vector.zero` is returned, instead.
    ///
    /// [arithmetic mean]: https://en.wikipedia.org/wiki/Arithmetic_mean
    @inlinable
    var average: Vector {
        (vertices.reduce(.zero, +) as Vector) / (max(1, Scalar(vertices.count)) as Scalar)
    }
}
