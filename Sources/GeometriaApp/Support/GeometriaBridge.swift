import Geometria
import SwiftBlend2D

typealias Vector = Vector2D
typealias Rectangle = Rectangle2D
typealias AABB = AABB2D
typealias Line = Line2D
typealias LineSegment = LineSegment2D
typealias Circle = Circle2D
typealias PolyLine = LinePolygon2D

extension Vector {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
    
    var asBLSize: BLSize {
        return BLSize(w: x, h: y)
    }
}

extension RectangleType where Vector == Vector2D {
    var asBLRect: BLRect {
        BLRect(location: location.asBLPoint, size: size.asBLSize)
    }
    
    var asBLBox: BLBox {
        asBLRect.asBLBox
    }
}

extension LineType where Vector == Vector2D {
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
