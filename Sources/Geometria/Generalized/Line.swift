import RealModule

/// Represents a [geometric line] as a pair of start and end N-dimensional vectors
/// which describe the two points an infinite line crosses.
///
/// [geometric line]: https://en.wikipedia.org/wiki/Line_(geometry)
public struct Line<Vector: VectorType>: LineType {
    public typealias Scalar = Vector.Scalar
    
    /// An initial point a line tracing from infinity passes through before
    /// being projected through `b` and extending to infinity in a straight line.
    public var a: Vector
    
    /// A secondary point a line tracing from `a` passes through before
    /// being projected to infinity in a straight line.
    public var b: Vector
    
    public var description: String {
        "\(type(of: self))(a: \(a), b: \(b))"
    }
    
    @_transparent
    public init(a: Vector, b: Vector) {
        self.a = a
        self.b = b
    }

    @_transparent
    public init<TLine: LineType>(_ line: TLine) where TLine.Vector == Vector {
        self.a = line.a
        self.b = line.b
    }
}

extension Line: Equatable where Vector: Equatable { }
extension Line: Hashable where Vector: Hashable { }
extension Line: Encodable where Vector: Encodable { }
extension Line: Decodable where Vector: Decodable { }

extension Line: LineAdditive where Vector: VectorAdditive {
    @_transparent
    public func offsetBy(_ vector: Vector) -> Self {
        Self(a: a + vector, b: b + vector)
    }
}

extension Line: LineMultiplicative where Vector: VectorMultiplicative {
    @_transparent
    public func withPointsScaledBy(_ factor: Vector) -> Self {
        Self(a: a * factor, b: b * factor)
    }
    
    @_transparent
    public func withPointsScaledBy(_ factor: Vector, around center: Vector) -> Self {
        let newA: Vector = (a - center) * factor + center
        let newB: Vector = (b - center) * factor + center
        
        return Self(a: newA, b: newB)
    }
}

extension Line: LineDivisible where Vector: VectorDivisible {
    
}

@_specializeExtension
extension Line: LineFloatingPoint & PointProjectableType & SignedDistanceMeasurableType where Vector: VectorFloatingPoint {
    /// Returns `true` for all non-NaN scalar values, which describes a
    /// [geometric line].
    ///
    /// This makes the line behave effectively like an infinitely long line when
    /// working with methods from ``LineFloatingPoint`` conformance.
    ///
    /// [geometric line]: https://en.wikipedia.org/wiki/Line_(geometry)
    @_transparent
    @_specialize(exported: true, kind: full, where Vector == Vector3D)
    public func containsProjectedNormalizedMagnitude(_ scalar: Vector.Scalar) -> Bool {
        !scalar.isNaN
    }
    
    /// Returns a projected normalized magnitude that is guaranteed to be
    /// contained in this line.
    ///
    /// For ``Line``, this is the full range of representable scalars, -∞ to ∞,
    /// resulting in the same value as `scalar` being returned for all inputs.
    @_transparent
    @_specialize(exported: true, kind: full, where Vector == Vector3D)
    public func clampProjectedNormalizedMagnitude(_ scalar: Vector.Scalar) -> Vector.Scalar {
        scalar
    }
}

extension Line: LineReal where Vector: VectorReal {
    
}
