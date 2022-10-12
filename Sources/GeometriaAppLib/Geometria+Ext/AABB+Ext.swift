#if canImport(Geometria)
import Geometria
#endif

extension AABB where Vector: VectorAdditive & VectorComparable {
    /// Initializes the smallest AABB capable of fully containing all of the
    /// provided AABB.
    ///
    /// If `aabbs` is empty, initializes `self` as `Self.zero`.
    @_transparent
    public init(of aabbs: [Self]) {
        let minimum = aabbs.map(\.minimum).reduce(.zero, Vector.pointwiseMin)
        let maximum = aabbs.map(\.maximum).reduce(.zero, Vector.pointwiseMax)

        self.init(minimum: minimum, maximum: maximum)
    }
}

extension AABB where Vector: VectorDivisible & VectorComparable {
    /// Subdivides this AABB into `2 ^ D` (where `D` is the dimensional size of
    /// `Self.Vector`) AABBs that occupy the same area as this AABB but subdivide
    /// it into equally-sized AABBs.
    ///
    /// The ordering of the subdivisions is not defined.
    @inlinable
    public func subdivided() -> [Self] {
        let center = self.center
        let vertices = self.vertices

        return vertices.map { v in
            Self(of: center, v)
        }
    }
}
