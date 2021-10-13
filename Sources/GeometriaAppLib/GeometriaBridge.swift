import SwiftBlend2D
import ImagineUI

#if canImport(simd)

import simd

/// Vector2 for Raytracing operations
public typealias RVector2D = SIMD2<Double>

/// Vector3 for Raytracing operations
public typealias RVector3D = SIMD3<Double>

#else

/// Vector2 for Raytracing operations
public typealias RVector2D = Vector2D

/// Vector3 for Raytracing operations
public typealias RVector3D = Vector3D

#endif

/// Rectangle for Raytracing operations
public typealias RRectangle = Rectangle2<RVector2D>

/// AABB2 for Raytracing operations
public typealias RAABB2D = AABB2<RVector2D>

/// AABB3 for Raytracing operations
public typealias RAABB3D = AABB3<RVector3D>

/// Cube3 for Raytracing operations
public typealias RCube3D = Cube3<RVector3D>

/// Line2 for Raytracing operations
public typealias RLine2D = Line2<RVector2D>

/// LineSegment2 for Raytracing operations
public typealias RLineSegment2D = LineSegment2<RVector2D>

/// Circle2 for Raytracing operations
public typealias RCircle2D = Circle2<RVector2D>

/// Sphere3 for Raytracing operations
public typealias RSphere3D = Sphere3<RVector3D>

/// Ellipse3 for Raytracing operations
public typealias REllipse3D = Ellipse3<RVector3D>

/// Cylinder3 for Raytracing operations
public typealias RCylinder3D = Cylinder3<RVector3D>

/// Disk3 for Raytracing operations
public typealias RDisk3D = Disk3<RVector3D>

/// LinePolygon2 for Raytracing operations
public typealias RPolyLine2D = LinePolygon2<RVector2D>

/// PointNormalPlane3 for Raytracing operations
public typealias RPlane3D = PointNormalPlane3<RVector3D>

/// Line3 for Raytracing operations
public typealias RLine3D = Line3<RVector3D>

/// Torus3 for Raytracing operations
public typealias RTorus3D = Torus3<RVector3D>

/// LineSegment3 for Raytracing operations
public typealias RLineSegment3D = LineSegment3<RVector3D>

/// DirectionalRay3 for Raytracing operations
public typealias RRay3D = DirectionalRay3<RVector3D>

/// PointNormal3 for Raytracing operations
public typealias RPointNormal3D = PointNormal<RVector3D>

/// ConvexLineIntersection for Raytracing operations
public typealias RConvexLineResult3D = ConvexLineIntersection<RVector3D>

/// Screen-space pixel coordinates
public typealias PixelCoord = UIIntPoint //Vector2i

/// Screen-space size
public typealias ViewportSize = UIIntSize //Vector2i

public extension RVector2D {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
    
    var asBLSize: BLSize {
        return BLSize(w: x, h: y)
    }

    init(_ point: UIIntPoint) {
        self.init(x: Double(point.x), y: Double(point.y))
    }

    init(_ size: UISize) {
        self.init(x: size.width, y: size.height)
    }

    init(_ size: UIIntSize) {
        self.init(x: Double(size.width), y: Double(size.height))
    }
}

public extension RectangleType where Vector == RVector2D {
    var asBLRect: BLRect {
        BLRect(location: location.asBLPoint, size: size.asBLSize)
    }
    
    var asBLBox: BLBox {
        asBLRect.asBLBox
    }
}

public extension LineType where Vector == RVector2D {
    var asBLLine: BLLine {
        BLLine(start: a.asBLPoint, end: b.asBLPoint)
    }
}

public extension RCircle2D {
    var asBLCircle: BLCircle {
        return BLCircle(center: center.asBLPoint, radius: radius)
    }
}

public extension RPolyLine2D {
    var asBLPath: BLPath {
        let path = BLPath()
        
        guard !vertices.isEmpty else {
            return path
        }
        
        path.moveTo(vertices[0].asBLPoint)
        
        for v in vertices.dropFirst() {
            path.lineTo(v.asBLPoint)
        }
        
        path.lineTo(vertices[0].asBLPoint)
        
        return path
    }
}

extension BLBoxI {
    public var location: BLPointI {
        BLPointI(x: x0, y: y0)
    }
    
    public var size: BLPointI {
        BLPointI(x: Int32(w), y: Int32(h))
    }
    
    public typealias Vector = BLPointI
    
    public init(location: Vector, size: Vector) {
        self.init(x: Int(location.x), y: Int(location.y), w: Int(size.x), h: Int(size.y))
    }
    
    public func union(_ other: Self) -> Self {
        return Self(x0: min(x0, other.x0), y0: min(y0, other.y0),
                    x1: max(x1, other.x1), y1: max(y1, other.y1))
    }
}

extension BLPointI {
    public typealias Scalar = Int32
    
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar)
    }
}

extension BLPoint: Vector2Type {
    public typealias Scalar = Double
    
    public var asVector: RVector2D {
        return RVector2D(x: x, y: y)
    }
    
    public var asUIVector: UIVector {
        return .init(x: x, y: y)
    }
    
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar)
    }
}

extension BLSize: Vector2Type {
    public typealias Scalar = Double
    
    public var asVector: RVector2D {
        return RVector2D(x: w, y: h)
    }
    
    public var asUIVector: UIVector {
        return .init(x: w, y: h)
    }
    
    public var x: Scalar {
        get { w }
        set { w = newValue }
    }
    public var y: Scalar {
        get { h }
        set { h = newValue }
    }
    
    public init(x: Scalar, y: Scalar) {
        self.init(w: x, h: y)
    }
    
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar)
    }
}

extension BLSizeI {
    public typealias Scalar = Int32

    public var asViewportSize: ViewportSize {
        return ViewportSize(width: Int(w), height: Int(h))
    }
    
    public var x: Scalar {
        get { w }
        set { w = newValue }
    }
    public var y: Scalar {
        get { h }
        set { h = newValue }
    }
    
    public init(x: Scalar, y: Scalar) {
        self.init(w: x, h: y)
    }
    
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar)
    }
}
