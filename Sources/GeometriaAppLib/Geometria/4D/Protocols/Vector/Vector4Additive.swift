/// Protocol for 4D vector types with additive scalars.
public protocol Vector4Additive: Vector4Type, VectorAdditive where SubVector3: Vector3Additive {
    /// Creates a new vector with the coordinates of a given ``Vector2Type``,
    /// and 0 on the ``z`` and ``w`` axis.
    init<V: Vector2Type>(_ vec: V)
    
    /// Creates a new vector with the coordinates of a given ``Vector3Type``,
    /// and 0 on the ``w`` axis.
    init<V: Vector3Type>(_ vec: V)
}

public extension Vector4Additive {
    /// Creates a new vector with the coordinates of a given ``Vector2Type``,
    /// and 0 on ``z`` and ``w`` axis.
    init<V: Vector2Type>(_ vec: V) {
        self.init(vec, z: .zero, w: .zero)
    }
    
    /// Creates a new vector with the coordinates of a given ``Vector3Type``,
    /// and 0 on the ``w`` axis.
    @_transparent
    init<V: Vector3Type>(_ vec: V) {
        self.init(vec, w: .zero)
    }
}
