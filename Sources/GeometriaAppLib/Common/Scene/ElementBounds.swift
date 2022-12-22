#if canImport(Geometria)
import Geometria
#endif

#if false // Sphere bounds

public typealias ElementBounds = RSphere3D

public extension ElementBounds {
    @_transparent
    static func makeBounds<T: BoundableType>(for value: T) -> ElementBounds where T.Vector == RVector3D {
        let bounds = value.bounds
        return RSphere3D(center: bounds.center, radius: bounds.size.maximalComponent / 2)
    }

    @_transparent
    static func makeBounds(for value: RSphere3D) -> ElementBounds {
        return value
    }
}

public extension RSphere3D {
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

public extension BoundingBoxElement {
    init(element: T) where T: BoundedElement {
        self.init(element: element, boundingBox: element.makeBounds().bounds)
    }
}

public extension BoundingSphereElement {
    init(element: T) where T: BoundedElement {
        self.init(element: element, boundingSphere: element.makeBounds())
    }
}

#else // AABB

public typealias ElementBounds = RAABB3D

public extension ElementBounds {
    @_transparent
    static func makeBounds<T: BoundableType>(for value: T) -> Self where T.Vector == RVector3D {
        value.bounds
    }
    
    @_transparent
    func rotated(_ transform: Transform3x3, rotationCenter: RVector3D) -> Self {
        var points = vertices

        points = points.map {
            transform.m.transformPoint($0 - rotationCenter) + rotationCenter
        }

        return Self(points: points)
    }
}

public extension Element {
    func makeBounded(by bounds: ElementBounds) -> BoundingBoxElement<Self> {
        .init(element: self, boundingBox: bounds)
    }

    func makeBounded<T: BoundableType>(by boundable: T) -> BoundingBoxElement<Self> where T.Vector == RVector3D {
        .init(element: self, boundingBox: boundable.bounds)
    }
}

public extension BoundingBoxElement {
    @_transparent
    init(element: T) where T: BoundedElement {
        self.init(element: element, boundingBox: element.makeBounds())
    }
}

public extension BoundingSphereElement {
    @_transparent
    init(element: T) where T: BoundedElement {
        let bounds = element.makeBounds()
        let boundsLength = bounds.maximum.distance(to: bounds.minimum)
        let sphere = RSphere3D(center: bounds.center, radius: boundsLength / 2)

        self.init(element: element, boundingSphere: sphere)
    }
}

#endif
