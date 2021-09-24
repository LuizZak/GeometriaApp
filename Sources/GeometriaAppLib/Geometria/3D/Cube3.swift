/// Represents a double-precision floating-point 3D cube.
public typealias Cube3D = NSquare<Vector3D>

/// Typealias for `NSquare<V>`, where `V` is constrained to ``Vector3Type``.
public typealias Cube3<V: Vector3Type> = NSquare<V>

public extension Cube3 {
    @_transparent
    init(x: Scalar, y: Scalar, z: Scalar, sideLength: Scalar) {
        self.init(location: .init(x: x, y: y, z: z), sideLength: sideLength)
    }
}

extension Cube3: Convex3Type where Vector: Vector3FloatingPoint {
    
}
