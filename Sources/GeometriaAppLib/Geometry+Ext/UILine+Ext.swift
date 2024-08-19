import Geometry

extension UILine {
    func offsetBy(x: Double, y: Double) -> Self {
        offsetBy(UIPoint(x: x, y: y))
    }

    func offsetBy(_ offset: UIPoint) -> Self {
        .init(start: start + offset, end: end + offset)
    }
}
