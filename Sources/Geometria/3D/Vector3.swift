import RealModule

/// A three-component vector type
public struct Vector3: Hashable, Codable, Vector3Type, CustomStringConvertible {
    public typealias Scalar = Double
    
    /// X coordinate of this vector
    public var x: Scalar
    
    /// Y coordinate of this vector
    public var y: Scalar
    
    /// Z coordinate of this vector
    public var z: Scalar
    
    /// Textual representation of this `Vector3`
    public var description: String {
        "\(type(of: self))(x: \(x), y: \(y), z: \(z))"
    }
    
    @_transparent
    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    @_transparent
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar, z: scalar)
    }
    
    /// Initializes this ``Vector3`` with the values from a given tuple.
    @_transparent
    public init(_ tuple: (Scalar, Scalar, Scalar)) {
        (x, y, z) = tuple
    }
}

// swiftlint:disable shorthand_operator
@_specializeExtension
extension Vector3: VectorComparable {
    /// Returns the pointwise minimal Vector where each component is the minimal
    /// scalar value at each index for both vectors.
    @_transparent
    public static func pointwiseMin(_ lhs: Self, _ rhs: Self) -> Self {
        Self(x: min(lhs.x, rhs.x), y: min(lhs.y, rhs.y), z: min(lhs.z, rhs.z))
    }
    
    /// Returns the pointwise maximal Vector where each component is the maximal
    /// scalar value at each index for both vectors.
    @_transparent
    public static func pointwiseMax(_ lhs: Self, _ rhs: Self) -> Self {
        Self(x: max(lhs.x, rhs.x), y: max(lhs.y, rhs.y), z: max(lhs.z, rhs.z))
    }
    
    /// Compares two vectors and returns `true` if all components of `lhs` are
    /// greater than `rhs`.
    ///
    /// Performs `lhs.x > rhs.x && lhs.y > rhs.y && lhs.z > rhs.z`
    @_transparent
    public static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.x > rhs.x && lhs.y > rhs.y && lhs.z > rhs.z
    }
    
    /// Compares two vectors and returns `true` if all components of `lhs` are
    /// greater than or equal to `rhs`.
    ///
    /// Performs `lhs.x >= rhs.x && lhs.y >= rhs.y && lhs.z >= rhs.z`
    @_transparent
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.x >= rhs.x && lhs.y >= rhs.y && lhs.z >= rhs.z
    }
    
    /// Compares two vectors and returns `true` if all components of `lhs` are
    /// less than `rhs`.
    ///
    /// Performs `lhs.x < rhs.x && lhs.y < rhs.y && lhs.z < rhs.z`
    @_transparent
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.x < rhs.x && lhs.y < rhs.y && lhs.z < rhs.z
    }
    
    /// Compares two vectors and returns `true` if all components of `lhs` are
    /// less than or equal to `rhs`.
    ///
    /// Performs `lhs.x <= rhs.x && lhs.y <= rhs.y && lhs.z <= rhs.z`
    @_transparent
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.x <= rhs.x && lhs.y <= rhs.y && lhs.z <= rhs.z
    }
}

@_specializeExtension
extension Vector3: AdditiveArithmetic {
    /// A zero-value `Vector3` value where each component corresponds to its
    /// representation of `0`.
    @_transparent
    public static var zero: Self {
        Self(x: .zero, y: .zero, z: .zero)
    }
}

@_specializeExtension
extension Vector3: VectorAdditive {
    @_transparent
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    @_transparent
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    @_transparent
    public static func + (lhs: Self, rhs: Scalar) -> Self {
        Self(x: lhs.x + rhs, y: lhs.y + rhs, z: lhs.z + rhs)
    }
    
    @_transparent
    public static func - (lhs: Self, rhs: Scalar) -> Self {
        Self(x: lhs.x - rhs, y: lhs.y - rhs, z: lhs.z - rhs)
    }
    
    @_transparent
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    @_transparent
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    @_transparent
    public static func += (lhs: inout Self, rhs: Scalar) {
        lhs = lhs + rhs
    }
    
    @_transparent
    public static func -= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs - rhs
    }
}

extension Vector3: VectorMultiplicative {
    /// A unit-value `Vector3Type` value where each component corresponds to its
    /// representation of `1`.
    @_transparent
    public static var one: Self {
        Self(repeating: 1)
    }
    
    /// Calculates the dot product between this and another provided `Vector3Type`
    @_transparent
    public func dot(_ other: Self) -> Scalar {
        // Doing this in separate statements to ease long compilation times in
        // Xcode 12
        let dx = x * other.x
        let dy = y * other.y
        let dz = z * other.z
        
        return dx + dy + dz
    }
    
    @_transparent
    public static func * (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    }
    
    @_transparent
    public static func * (lhs: Self, rhs: Scalar) -> Self {
        Self(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    @_transparent
    public static func * (lhs: Scalar, rhs: Self) -> Self {
        Self(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
    }
    
    @_transparent
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
    @_transparent
    public static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * rhs
    }
}

extension Vector3: Vector3Additive {
    
}

extension Vector3: Vector3Multiplicative {
    
}

extension Vector3: VectorSigned {
    /// Returns a `Vector3` where each component is the absolute value of the
    /// components of this `Vector3`.
    @_transparent
    public var absolute: Self {
        Self(x: abs(x), y: abs(y), z: abs(z))
    }
    
    @_transparent
    public var sign: Self {
        Self(x: x < 0 ? -1 : (x > 0 ? 1 : 0),
             y: y < 0 ? -1 : (y > 0 ? 1 : 0),
             z: z < 0 ? -1 : (z > 0 ? 1 : 0))
    }
    
    /// Negates this Vector
    @_transparent
    public static prefix func - (lhs: Self) -> Self {
        Self(x: -lhs.x, y: -lhs.y, z: -lhs.z)
    }
}

extension Vector3: VectorDivisible {
    @_transparent
    public static func / (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }
    
    @_transparent
    public static func / (lhs: Self, rhs: Scalar) -> Self {
        Self(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    @_transparent
    public static func / (lhs: Scalar, rhs: Self) -> Self {
        Self(x: lhs / rhs.x, y: lhs / rhs.y, z: lhs / rhs.z)
    }
    
    @_transparent
    public static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
    
    @_transparent
    public static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
}
// swiftlint:enable shorthand_operator

extension Vector3: VectorFloatingPoint {
    /// Returns the result of adding the product of the two given vectors to this
    /// vector, computed without intermediate rounding.
    ///
    /// This method is equivalent to calling C `fma` function on each component.
    ///
    /// - Parameters:
    ///   - lhs: One of the vectors to multiply before adding to this vector.
    ///   - rhs: The other vector to multiply.
    /// - Returns: The product of `lhs` and `rhs`, added to this vector.
    @_transparent
    public func addingProduct(_ a: Self, _ b: Self) -> Self {
        // TODO: Seeing very small performance degradations with fma on Windows, check causes more thoroughly later
        #if os(Windows)
        self + a * b
        #else
        Self(x: x.addingProduct(a.x, b.x), y: y.addingProduct(a.y, b.y), z: z.addingProduct(a.z, b.z))
        #endif
    }
    
    /// Returns the result of adding the product of the given scalar and vector
    /// to this vector, computed without intermediate rounding.
    ///
    /// This method is equivalent to calling C `fma` function on each component.
    ///
    /// - Parameters:
    ///   - lhs: A scalar to multiply before adding to this vector.
    ///   - rhs: A vector to multiply.
    /// - Returns: The product of `lhs` and `rhs`, added to this vector.
    @_transparent
    public func addingProduct(_ a: Scalar, _ b: Self) -> Self {
        #if os(Windows)
        self + a * b
        #else
        Self(x: x.addingProduct(a, b.x), y: y.addingProduct(a, b.y), z: z.addingProduct(a, b.z))
        #endif
    }
    
    /// Returns the result of adding the product of the given vector and scalar
    /// to this vector, computed without intermediate rounding.
    ///
    /// This method is equivalent to calling C `fma` function on each component.
    ///
    /// - Parameters:
    ///   - lhs: A vector to multiply before adding to this vector.
    ///   - rhs: A scalar to multiply.
    /// - Returns: The product of `lhs` and `rhs`, added to this vector.
    @_transparent
    public func addingProduct(_ a: Self, _ b: Scalar) -> Self {
        #if os(Windows)
        self + a * b
        #else
        Self(x: x.addingProduct(a.x, b), y: y.addingProduct(a.y, b), z: z.addingProduct(a.z, b))
        #endif
    }
    
    /// Rounds the components of this `Vector3Type` using a given
    /// `FloatingPointRoundingRule`.
    @_transparent
    public func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        Self(x: x.rounded(rule), y: y.rounded(rule), z: z.rounded(rule))
    }
    
    /// Rounds the components of this `Vector3Type` using a given
    /// `FloatingPointRoundingRule.toNearestOrAwayFromZero`.
    ///
    /// Equivalent to calling C's round() function on each component.
    @_transparent
    public func rounded() -> Self {
        rounded(.toNearestOrAwayFromZero)
    }
    
    /// Rounds the components of this `Vector3Type` using a given
    /// `FloatingPointRoundingRule.up`.
    ///
    /// Equivalent to calling C's ceil() function on each component.
    @_transparent
    public func ceil() -> Self {
        rounded(.up)
    }
    
    /// Rounds the components of this `Vector3Type` using a given
    /// `FloatingPointRoundingRule.down`.
    ///
    /// Equivalent to calling C's floor() function on each component.
    @_transparent
    public func floor() -> Self {
        rounded(.down)
    }
    
    @_transparent
    public static func % (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x.truncatingRemainder(dividingBy: rhs.x),
             y: lhs.y.truncatingRemainder(dividingBy: rhs.y),
             z: lhs.z.truncatingRemainder(dividingBy: rhs.z))
    }
    
    @_transparent
    public static func % (lhs: Self, rhs: Scalar) -> Self {
        Self(x: lhs.x.truncatingRemainder(dividingBy: rhs),
             y: lhs.y.truncatingRemainder(dividingBy: rhs),
             z: lhs.z.truncatingRemainder(dividingBy: rhs))
    }
}

extension Vector3: SignedDistanceMeasurableType {
    @_transparent
    public func signedDistance(to other: Self) -> Scalar {
        (self - other).length
    }
}

extension Vector3: Vector3FloatingPoint {
    
}

extension Vector3: VectorReal {
    @_transparent
    public static func pow(_ vec: Self, _ exponent: Int) -> Self {
        Self(x: Scalar.pow(vec.x, exponent),
             y: Scalar.pow(vec.y, exponent),
             z: Scalar.pow(vec.z, exponent))
    }
    
    @_transparent
    public static func pow(_ vec: Self, _ exponent: Self) -> Self {
        Self(x: Scalar.pow(vec.x, exponent.x),
             y: Scalar.pow(vec.y, exponent.y),
             z: Scalar.pow(vec.z, exponent.z))
    }
}

extension Vector3: Vector3Real {
    /// The XY-plane angle of this vector
    @_transparent
    public var azimuth: Scalar {
        Scalar.atan2(y: y, x: x)
    }
    
    /// The elevation angle of this vector, or the angle between the XY plane
    /// and the vector.
    ///
    /// Returns zero, if the vector's length is zero.
    @inlinable
    public var elevation: Scalar {
        let l = length
        if l == .zero {
            return .zero
        }
        
        return Scalar.asin(z / l)
    }
}