import WinSDK
import Geometria

public struct Point {
    public static let zero: Self = .init(x: 0, y: 0)

    public var x: Int
    public var y: Int
}

public struct Size {
    public static let zero: Self = .init(width: 0, height: 0)

    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public struct Rect {
    public var origin: Point
    public var size: Size
}

extension Rect {
    internal init(from: RECT) {
        self.origin = Point(x: Int(from.left), y: Int(from.top))
        self.size = Size(width: Int(from.right - from.left),
                         height: Int(from.bottom - from.top))
    }
}

extension RECT {
    internal init(from: Rect) {
        self.init(left: LONG(from.origin.x),
                  top: LONG(from.origin.y),
                  right: LONG(from.origin.x + from.size.width),
                  bottom: LONG(from.origin.y + from.size.height))
    }
}

extension Point {
    internal init(from: POINT) {
        self.init(x: Int(from.x), y: Int(from.y))
    }
}

extension POINT {
    internal init(from: Point) {
        self.init(x: LONG(from.x), y: LONG(from.y))
    }
}

extension Size {
    internal init(from: POINT) {
        self.init(width: Int(from.x), height: Int(from.y))
    }
}

extension POINT {
    internal init(from: Size) {
        self.init(x: LONG(from.width), y: LONG(from.height))
    }
}

extension Point {
    internal init<Integer: FixedWidthInteger>(x: Integer, y: Integer) {
        self.init(x: Int(x), y: Int(y))
    }
}
