import ImagineUI
import Blend2DRenderer

enum GraphBuilderIconLibrary {
    public static let addIcon: Image = makeIcon(.yellow, size: .init(width: 10, height: 10)) { (renderer, size) in
        let sizePoint = size.asUIPoint

        func rounded(_ p: UIPoint) -> UIPoint {
            UIPoint(x: p.x.rounded(), y: p.y.rounded())
        }

        func line(start: UIPoint, end: UIPoint) {
            renderer.strokeLine(
                start: rounded(start),
                end: rounded(end)
            )
        }

        let center = UIPoint(size) / 2

        line(start: UIPoint(x: 0, y: center.y), end: UIPoint(x: size.width, y: center.y))
        line(start: UIPoint(x: center.x, y: 0), end: UIPoint(x: center.x, y: size.height))
    }

    private static func makeIcon(
        _ strokeColor: Color,
        size: UIIntSize = .init(width: 12, height: 12),
        rendering closure: (Renderer, UISize) -> Void
    ) -> Image {
        let context = Blend2DRendererContext().createImageRenderer(width: size.width, height: size.height)
        return context.withRenderer { renderer in
            renderer.clear()
            renderer.setStroke(strokeColor)

            closure(renderer, UISize(size))
        }
    }
}

private protocol WithMutableType {
    func with<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) -> Self
}

extension WithMutableType {
    func with<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}

extension UICircleArc: WithMutableType { }
extension UIEllipseArc: WithMutableType { }
extension UIBezier: WithMutableType { }
extension UICircle: WithMutableType { }
extension UIEllipse: WithMutableType { }
extension UIIntPoint: WithMutableType { }
extension UIIntRectangle: WithMutableType { }
extension UIIntSize: WithMutableType { }
extension UILine: WithMutableType { }
extension UIMatrix: WithMutableType { }
extension UIPoint: WithMutableType { }
extension UIPolygon: WithMutableType { }
extension UIRectangle: WithMutableType { }
extension UIRoundRectangle: WithMutableType { }
extension UISize: WithMutableType { }
extension UITriangle: WithMutableType { }
