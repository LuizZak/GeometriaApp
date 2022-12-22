@_transparent
public func mix<T: FloatingPoint>(_ lhs: T, _ rhs: T, factor: T) -> T {
    lhs * (1 - factor) + rhs * factor
}
