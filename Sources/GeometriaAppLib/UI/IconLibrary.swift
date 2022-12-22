import ImagineUI
import Blend2DRenderer

public class IconLibrary {
    // MARK: - Red icons (geometry primitives)

    public static let aabbIcon: Image = makeAABBIcon(.lightCoral)

    public static let cubeIcon: Image = makeAABBIcon(.lightCoral, aabbSizeScale: .init(x: 0.6, y: 0.6))

    public static let sphereIcon: Image = makeIcon(.lightCoral) { (renderer, size) in
        let circle = UICircle(center: size.asUIPoint / 2, radius: size.width * 0.45)
        let horizon = circle.asUIEllipse.scaledBy(x: 1.0, y: 0.3).arc(start: .zero, sweep: .pi)
        let meridian = circle.asUIEllipse.scaledBy(x: 0.3, y: 1.0).arc(start: -.pi / 2, sweep: .pi)

        renderer.stroke(circle)
        renderer.stroke(horizon)
        renderer.stroke(meridian)
    }

    public static let cylinderIcon: Image = makeIcon(.lightCoral) { (renderer, size) in
        let top = UIEllipse(
            center: .init(x: size.width / 2, y: size.height * 0.25),
            radius: .init(x: size.width / 2, y: size.height * 0.2)
        )
        let bottom = top
            .offsetBy(x: 0, y: size.height * 0.5)
            .arc(start: .zero, sweep: .pi)

        renderer.stroke(top)
        renderer.stroke(bottom)
        renderer.stroke(UILine(x1: top.bounds.left, y1: top.center.y, x2: top.bounds.left, y2: size.height * 0.75))
        renderer.stroke(UILine(x1: top.bounds.right, y1: top.center.y, x2: top.bounds.right, y2: size.height * 0.75))
    }

    public static let diskIcon: Image = makeIcon(.lightCoral) { (renderer, size) in
        let disk = UICircle(center: size.asUIPoint / 2, radius: size.width * 0.45)
            .asUIEllipse
            .scaledBy(x: 0.6, y: 1.0)

        renderer.stroke(disk)
    }

    // MARK: - Blue icons (structural elements)

    public static let repeatTranslateIcon: Image = makeIcon(.blue) { (renderer, size) in
        let circle1 = UICircle(center: size.asUIPoint * UIVector(x: 0.25, y: 0.25), radius: size.width * 0.22)
        let circle2 = circle1.offsetBy(x: size.width * 0.2, y: size.width * 0.2)
        let circle3 = circle2.offsetBy(x: size.width * 0.2, y: size.height * 0.2)

        renderer.setFill(.white)
        
        renderer.stroke(circle1)

        renderer.fill(circle2)
        renderer.stroke(circle2)

        renderer.fill(circle3)
        renderer.stroke(circle3)
    }

    public static let boundingBoxIcon: Image = makeAABBIcon(.cornflowerBlue)

    public static let tupleIcon: Image = makeIcon(.cornflowerBlue) { (renderer, size) in
        let circleLeft = UICircle(
            center: .init(x: size.width, y: size.height / 2),
            radius: size.width * (10.0 / 12.0)
        )
        let circleRight = UICircle(
            center: .init(x: 0, y: size.height / 2),
            radius: size.width * (10.0 / 12.0)
        )

        renderer.stroke(circleLeft)
        renderer.stroke(circleRight)
    }

    public static let intersectionIcon: Image = makeIcon(.cornflowerBlue) { (renderer, size) in
        let sizePoint = size.asUIPoint
        
        let square = UIRectangle(location: sizePoint * 0.2, size: size * 0.6)
        let circle = UICircle(center: square.bottomRight, radius: square.width * 0.65)
        let pie = circle.arc(start: -.pi / 2, sweep: -.pi / 2)
    
        renderer.withTemporaryState {
            renderer.setStroke(.lightGray.withTransparency(30))
            renderer.stroke(square)
            renderer.stroke(circle)
        }

        renderer.stroke(pie: pie)
    }

    public static let subtractionIcon: Image = makeIcon(.cornflowerBlue) { (renderer, size) in
        let sizePoint = size.asUIPoint

        var poly = UIPolygon(vertices: [
            sizePoint * 0.2,
            sizePoint * UIVector(x: 0.8, y: 0.2),
            sizePoint * UIVector(x: 0.8, y: 0.5),
            sizePoint * UIVector(x: 0.5, y: 0.5),
            sizePoint * UIVector(x: 0.5, y: 0.8),
            sizePoint * UIVector(x: 0.2, y: 0.8),
        ])
        poly.close()

        renderer.stroke(poly)
    }

    // MARK: - Green icons (data types)

    public static let matrixIcon: Image = makeIcon(.green) { (renderer, size) in
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

        line(
            start: sizePoint * UIVector(x: 1.0 / 3.0, y: 0.0),
            end: sizePoint * UIVector(x: 1.0 / 3.0, y: 1.0)
        )
        line(
            start: sizePoint * UIVector(x: 2.0 / 3.0, y: 0.0),
            end: sizePoint * UIVector(x: 2.0 / 3.0, y: 1.0)
        )
        
        line(
            start: sizePoint * UIVector(x: 0.0, y: 1.0 / 3.0),
            end: sizePoint * UIVector(x: 1.0, y: 1.0 / 3.0)
        )
        line(
            start: sizePoint * UIVector(x: 0.0, y: 2.0 / 3.0),
            end: sizePoint * UIVector(x: 1.0, y: 2.0 / 3.0)
        )
    }

    // MARK: -

    private static func makeAABBIcon(_ color: Color, aabbSizeScale: UIVector = UIVector(x: 0.6, y: 0.4)) -> Image {
        makeIcon(color) { (renderer, size) in
            let aabb = UIRectangle(x: size.width * 0.1, y: size.height * 0.4, width: size.width * aabbSizeScale.x, height: size.height * aabbSizeScale.y)
            var polygon = UIPolygon()
            polygon.addVertex(aabb.topLeft)
            polygon.addVertex(aabb.topRight)
            polygon.addVertex(aabb.bottomRight)
            polygon.addVertex(aabb.bottomLeft)
            polygon.close()

            let topEdge =
                UILine(start: aabb.topLeft, end: aabb.topRight)
                    .offsetBy(x: size.width * 0.2, y: -size.height * 0.2)
            let rightEdge =
                UILine(start: aabb.topRight, end: aabb.bottomRight)
                    .offsetBy(x: size.width * 0.2, y: -size.height * 0.2)

            renderer.stroke(polygon)
            renderer.stroke(topEdge)
            renderer.stroke(rightEdge)
            renderer.strokeLine(start: aabb.topLeft, end: topEdge.start)
            renderer.strokeLine(start: aabb.topRight, end: topEdge.end)
            renderer.strokeLine(start: aabb.bottomRight, end: rightEdge.end)
        }
    }

    private static func makeIcon(_ color: Color, rendering closure: (Renderer, UISize) -> Void) -> Image {
        let size = UIIntSize(width: 12, height: 12)
        let context = Blend2DRendererContext().createImageRenderer(width: size.width, height: size.height)
        context.renderer.clear()
        context.renderer.setStroke(color)

        closure(context.renderer, UISize(size))

        return context.renderedImage()
    }
}
