/// Represents a double-precision floating-point 2D square.
public typealias Square2D = Square2<Vector2D>

/// Typealias for `NSquare<V>`, where `V` is constrained to ``Vector2Type``.
public typealias Square2<V: Vector2Type> = NSquare<V>

public extension Square2 {
    @_transparent
    init(x: Scalar, y: Scalar, sideLength: Scalar) {
        self.init(location: .init(x: x, y: y), sideLength: sideLength)
    }
}

extension Square2: Convex2Type where Vector: Vector2FloatingPoint {
    
}
