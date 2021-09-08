import Geometria
import SwiftBlend2D
import ImagineUI

typealias UIVector = ImagineUI.Vector
typealias UIRectangle = ImagineUI.Rectangle

/// Vector2 for Raytracing operations
typealias RVector2D = SIMD2<Double>

/// Vector3 for Raytracing operations
typealias RVector3D = SIMD3<Double>

/// Rectangle for Raytracing operations
typealias RRectangle = Rectangle2<RVector2D>

/// AABB2 for Raytracing operations
typealias RAABB2D = AABB2<RVector2D>

/// AABB3 for Raytracing operations
typealias RAABB3D = AABB3<RVector3D>

/// Line2 for Raytracing operations
typealias RLine2D = Line2<RVector2D>

/// LineSegment2 for Raytracing operations
typealias RLineSegment2D = LineSegment2<RVector2D>

/// Circle2 for Raytracing operations
typealias RCircle2D = Circle2<RVector2D>

/// LinePolygon2 for Raytracing operations
typealias RPolyLine2D = LinePolygon2<RVector2D>

/// PointNormalPlane3 for Raytracing operations
typealias RPlane3D = PointNormalPlane3<RVector3D>

/// DirectionalRay3 for Raytracing operations
typealias RRay3D = DirectionalRay3<RVector3D>

extension RVector2D {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
    
    var asBLSize: BLSize {
        return BLSize(w: x, h: y)
    }
}

extension Vector2i {
    var asBLPointI: BLPointI {
        BLPointI(x: Int32(x), y: Int32(y))
    }
}

extension RectangleType where Vector == RVector2D {
    var asBLRect: BLRect {
        BLRect(location: location.asBLPoint, size: size.asBLSize)
    }
    
    var asBLBox: BLBox {
        asBLRect.asBLBox
    }
}

extension LineType where Vector == RVector2D {
    var asBLLine: BLLine {
        BLLine(start: a.asBLPoint, end: b.asBLPoint)
    }
}

extension RCircle2D {
    var asBLCircle: BLCircle {
        return BLCircle(center: center.asBLPoint, radius: radius)
    }
}

extension RPolyLine2D {
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

extension BLBoxI: ConstructableRectangleType {
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
    
    func union(_ other: Self) -> Self {
        return Self(x0: min(x0, other.x0), y0: min(y0, other.y0),
                    x1: max(x1, other.x1), y1: max(y1, other.y1))
    }
}

extension BLPointI: Vector2Type {
    public typealias Scalar = Int32
    
    var asVector: Vector2i {
        Vector2i(x: .init(x), y: .init(y))
    }
    
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar)
    }
}

extension BLPoint: Vector2Type {
    public typealias Scalar = Double
    
    var asVector: RVector2D {
        return RVector2D(x: x, y: y)
    }
    
    var asUIVector: UIVector {
        return .init(x: x, y: y)
    }
    
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar)
    }
}

extension BLSize: Vector2Type {
    public typealias Scalar = Double
    
    var asVector: RVector2D {
        return RVector2D(x: w, y: h)
    }
    
    var asUIVector: UIVector {
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


extension BLSizeI: Vector2Type {
    public typealias Scalar = Int32
    
    var asVector2i: Vector2i {
        return Vector2i(x: Int(w), y: Int(h))
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
