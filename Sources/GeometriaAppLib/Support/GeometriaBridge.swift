import Geometria
import SwiftBlend2D

typealias _Vector = Vector
typealias Vector = SIMD2<Double>
typealias Vector3D = SIMD3<Double>
typealias Rectangle = Rectangle2<Vector>
typealias AABB = AABB2<Vector>
typealias Line = Line2<Vector>
typealias LineSegment = LineSegment2<Vector>
typealias Circle = Circle2<Vector>
typealias PolyLine = LinePolygon2<Vector>
typealias Plane = PointNormalPlane3<Vector3D>
typealias Ray = DirectionalRay3<Vector3D>
typealias AABB3D = AABB3<Vector3D>

extension Vector {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
    
    var asBLSize: BLSize {
        return BLSize(w: x, h: y)
    }
}

extension RectangleType where Vector == _Vector {
    var asBLRect: BLRect {
        BLRect(location: location.asBLPoint, size: size.asBLSize)
    }
    
    var asBLBox: BLBox {
        asBLRect.asBLBox
    }
}

extension LineType where Vector == _Vector {
    var asBLLine: BLLine {
        BLLine(start: a.asBLPoint, end: b.asBLPoint)
    }
}

extension Circle {
    var asBLCircle: BLCircle {
        return BLCircle(center: center.asBLPoint, radius: radius)
    }
}

extension PolyLine {
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
    
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar)
    }
}

extension BLPoint: Vector2Type {
    public typealias Scalar = Double
    
    var asVector: Vector {
        return Vector(x: x, y: y)
    }
    
    public init(repeating scalar: Scalar) {
        self.init(x: scalar, y: scalar)
    }
}

extension BLSize: Vector2Type {
    public typealias Scalar = Double
    
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
