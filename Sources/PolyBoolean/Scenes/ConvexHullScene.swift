import Foundation
import ImagineUI
import Geometria
import GeometriaClipping

class ConvexHullScene: PolyBooleanScene {
    var polys: [any ParametricClip2Geometry] = []
    var circles: [DemoCircle] = []
    var mousePoly: Circle2Parametric = .init(circle: .unit)

    override func initialize(size: UIIntSize) {
        super.initialize(size: size)

        let sizeVec = self.size.asVector2D

        spawnCircles()

        polys = [
        ]
        mousePoly.circle2.radius = sizeVec.x / 20
    }

    func spawnCircles() {
        circles.removeAll()

        let count = 10
        let radiusRange: ClosedRange<Double> = 25.0...50.0
        let velocityRange: ClosedRange<Double> = -100.0...100.0
        let sizeVec = self.size.asVector2D

        // Spawn a large, immobile circle in the center
        circles.append(
            .init(
                circle: .init(
                    center: sizeVec / 2,
                    radius: sizeVec.minimalComponent / 3,
                    startPeriod: 0.0,
                    endPeriod: 1.0
                ),
                velocity: .zero
            )
        )

        for _ in 0..<count {
            let radius = Double.random(in: radiusRange)
            let spawnBounds = AABB(minimum: .init(repeating: radius), maximum: sizeVec - radius)
            let spawnX = Double.random(in: spawnBounds.minimum.x...spawnBounds.maximum.x)
            let spawnY = Double.random(in: spawnBounds.minimum.y...spawnBounds.maximum.y)
            let velocityX = Double.random(in: velocityRange)
            let velocityY = Double.random(in: velocityRange)

            let circle = Circle2Parametric(
                center: .init(x: spawnX, y: spawnY),
                radius: radius,
                startPeriod: 0.0,
                endPeriod: 1.0
            )

            let demoCircle = DemoCircle(
                circle: circle,
                velocity: .init(x: velocityX, y: velocityY)
            )

            circles.append(demoCircle)
        }
    }

    func effectivePolys() -> [any ParametricClip2Geometry] {
        let sizeVec = self.size.asVector2D

        var result: [any ParametricClip2Geometry] = []

        // Convex hull
        do {
            let pointCloud = PointCloud2(points: circles.map(\.circle.center))
            let convexHull = pointCloud.grahamScanConvexHull()
            let polygon = LinePolygon2D(vertices: convexHull.points.reversed())
            let polygonParametric = LinePolygon2Parametric(
                linePolygon2: polygon,
                startPeriod: 0.0,
                endPeriod: 1.0
            )

            result.append(polygonParametric)
        }

        // Negative bar
        do {
            let aabb = AABB2D(
                left: 0,
                top: sizeVec.y * 0.475,
                right: sizeVec.x,
                bottom: sizeVec.y * 0.525
            )
            let polygon = aabb.asLinePolygon2
            let polygonParametric = LinePolygon2Parametric(
                linePolygon2: polygon,
                startPeriod: 0.0,
                endPeriod: 1.0
            )

            result.append(polygonParametric)
        }

        result.append(contentsOf: polys)

        if isMouseDown {
            result.append(mousePoly)
        }

        return result
    }

    override func update(_ delta: TimeInterval) {
        super.update(delta)

        circles = circles.map { circle in
            circle.updating(
                delta,
                bounds: .init(location: .zero, size: self.size.asVector2D)
            )
        }
    }

    override func mouseMove(_ event: MouseEventArgs) {
        super.mouseMove(event)

        mousePoly.circle2.center = event.location.asVector2D
    }

    override func render(in renderer: any Renderer, clipRegion: any ClipRegionType) {
        super.render(in: renderer, clipRegion: clipRegion)

        let polys = effectivePolys()
        renderSubtraction(polys: polys, renderer: renderer)
    }
}
