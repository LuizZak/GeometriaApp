import Foundation
import ImagineUI
import Geometria
import GeometriaClipping

class CapsuleSegmentsScene: PolyBooleanScene {
    var polys: [any ParametricClip2Geometry<Vector2D>] = []
    var segments: [CapsuleSegment] = []
    var mousePoly: Circle2Parametric<Vector2D> = .init(circle: .unit)

    override func initialize(size: UIIntSize) {
        super.initialize(size: size)

        let sizeVec = self.size.asVector2D

        spawnSegments()

        polys = []
        mousePoly.circle2.radius = sizeVec.x / 20
    }

    func spawnSegments() {
        segments.removeAll()

        let count = 7
        let radiusRange: ClosedRange<Double> = 25.0...50.0
        let velocityRange: ClosedRange<Double> = -100.0...100.0
        let sizeVec = self.size.asVector2D

        for _ in 0..<count {
            let radius = Double.random(in: radiusRange)
            let spawnBounds = AABB(minimum: .init(repeating: radius), maximum: sizeVec - radius)
            let spawnX = Double.random(in: spawnBounds.minimum.x...spawnBounds.maximum.x)
            let spawnY = Double.random(in: spawnBounds.minimum.y...spawnBounds.maximum.y)
            let velocityX = Double.random(in: velocityRange)
            let velocityY = Double.random(in: velocityRange)

            let location = Vector2D(x: spawnX, y: spawnY)

            let demoCircle = CapsuleSegment(
                location: location,
                radius: radius,
                velocity: .init(x: velocityX, y: velocityY)
            )

            segments.append(demoCircle)
        }
    }

    func effectivePolys() -> [any ParametricClip2Geometry<Vector2D>] {
        var result: [Capsule2Parametric<Vector2D>] = []

        if var previous = segments.first {
            for next in segments.dropFirst() {
                defer { previous = next }

                let capsule = Capsule2Parametric<Vector2D>(
                    start: previous.location,
                    startRadius: previous.radius,
                    end: next.location,
                    endRadius: next.radius,
                    startPeriod: 0,
                    endPeriod: 1
                )

                result.append(capsule)
            }
        }

        return result
    }

    override func update(_ delta: TimeInterval) {
        super.update(delta)

        segments = segments.map { segment in
            segment.updating(
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
        renderUnion(polys: polys, tolerance: 1e-5, renderer: renderer)
    }

    struct CapsuleSegment {
        var location: Vector2D
        var radius: Double
        var velocity: Vector2D

        var bounds: AABB2D {
            .init(center: location, size: .init(repeating: radius * 2))
        }

        func updating(_ dt: TimeInterval, bounds: AABB2D) -> Self {
            var copy = self
            copy.update(dt, bounds: bounds)
            return copy
        }

        mutating func update(_ dt: TimeInterval, bounds: AABB2D) {
            // Make sure we can travel before updating the positions
            guard radius < bounds.width && radius < bounds.height else {
                return
            }

            location += velocity * dt
            let segmentBounds = self.bounds

            if segmentBounds.left <= bounds.minimum.x {
                velocity.x = velocity.x.magnitude
            } else if segmentBounds.right >= bounds.maximum.x {
                velocity.x = -(velocity.x.magnitude)
            }
            if segmentBounds.top < bounds.minimum.y {
                velocity.y = velocity.y.magnitude
            } else if segmentBounds.bottom >= bounds.maximum.y {
                velocity.y = -(velocity.y.magnitude)
            }
        }
    }
}
