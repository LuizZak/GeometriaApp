#if false // Sphere bounds

typealias RaymarchingBounds = RSphere3D

extension RaymarchingBounds {
    @_transparent
    static func makeBounds<T: BoundableType>(for value: T) -> RaymarchingBounds where T.Vector == RVector3D {
        let bounds = value.bounds
        return RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
    }

    @_transparent
    static func makeBounds(for value: RSphere3D) -> RaymarchingBounds {
        return value
    }
}

extension RSphere3D {
    static let zero: Self = .init(center: .zero, radius: .zero)

    /// Returns the smallest sphere capable of containing both `self` and the 
    /// provided sphere.
    @_transparent
    func union(_ other: RSphere3D) -> RSphere3D {
        let newCenter = (center + other.radius) / 2
        let dist = center.distance(to: other.center)
        let newRadius = dist + radius + other.radius

        return .init(center: newCenter, radius: newRadius)
    }

    /// Returns a copy of this N-sphere with its center offset by a given Vector
    /// amount.
    ///
    /// ```swift
    /// let circle = Circle2D(x: 20, y: 30, radius: 50)
    ///
    /// let result = circle.offsetBy(.init(x: 5, y: 10))
    ///
    /// print(result) // Prints "(center: (x: 25, y: 40), radius: 50)"
    /// ```
    @_transparent
    func offsetBy(_ vector: Vector) -> Self {
        Self(center: center + vector, radius: radius)
    }
}

extension BoundingBoxRaymarchingElement {
    init(element: T) where T: BoundedRaymarchingElement {
        self.init(element: element, boundingBox: element.makeBounds().bounds)
    }
}

extension BoundingSphereRaymarchingElement {
    init(element: T) where T: BoundedRaymarchingElement {
        self.init(element: element, boundingSphere: element.makeBounds())
    }
}

#else // AABB

typealias RaymarchingBounds = RAABB3D

extension RaymarchingBounds {
    @_transparent
    static func makeBounds<T: BoundableType>(for value: T) -> Self where T.Vector == RVector3D {
        value.bounds
    }
}

extension BoundingBoxRaymarchingElement {
    init(element: T) where T: BoundedRaymarchingElement {
        self.init(element: element, boundingBox: element.makeBounds())
    }
}

extension BoundingSphereRaymarchingElement {
    init(element: T) where T: BoundedRaymarchingElement {
        let bounds = element.makeBounds()
        let sphere = RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)

        self.init(element: element, boundingSphere: sphere)
    }
}

#endif
