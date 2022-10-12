/// Represents a 2D line as a pair of double-precision floating-point vectors
/// which the infinite line crosses.
public typealias Line2D = Line2<Vector2D>

/// Typealias for `Line<V>`, where `V` is constrained to ``Vector2Type``.
public typealias Line2<V: Vector2Type> = Line<V>

@_specializeExtension
extension Line2: Line2Type {
    @_transparent
    @_specialize(exported: true, kind: full, where Vector == Vector2D)
    public init(x1: Scalar, y1: Scalar, x2: Scalar, y2: Scalar) {
        a = Vector(x: x1, y: y1)
        b = Vector(x: x2, y: y2)
    }
}

extension Line2: Line2FloatingPoint where Vector: Vector2FloatingPoint {
    
}

extension Line2: Line2Real where Vector: Vector2Real {
    
}
