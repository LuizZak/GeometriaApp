import Foundation
import ImagineUI
import SwiftBlend2D
import Geometria
import GeometriaClipping

open class PolyBooleanApp: ImagineUIWindowContent {
    var _updateTimer: SchedulerTimerType?

    var isMouseDown: Bool = false
    var isShiftHeld: Bool = false

    var strokeAnimation: Double = 0 {
        didSet {
            if strokeAnimation != oldValue {
                invalidateScreen()
            }
        }
    }

    #if true

    var polys: [any ParametricClip2Geometry] = []
    var circles: [DemoCircle] = []
    var mousePoly: Circle2Parametric = .init(circle: .unit)

    #else

    var polys: [any PolyBooleanType] = []
    var mousePoly: CirclePoly = .init(circle: .unit)

    #endif

    let labelStackView = StackView(orientation: .vertical)
    let intersectCountLabel = Label(textColor: .black, fontSize: 20)
    let mouseLocationLabel = Label(textColor: .black, fontSize: 20)

    #if true
    func effectivePolys() -> [any ParametricClip2Geometry] {
        if isMouseDown {
            return circles.map({ $0.makeHollow() }) + polys + [mousePoly]
        }

        return circles.map({ $0.makeHollow() }) + polys
    }
    #else
    func effectivePolys() -> [any PolyBooleanType] {
        if isMouseDown {
            return polys + [mousePoly]
        }

        return polys
    }
    #endif

    open override func initialize() {
        super.initialize()

        _updateTimer = Scheduler.instance.scheduleTimer(interval: 1 / 60.0, repeats: true) { [weak self] in
            self?.update(UISettings.timeInSeconds())
        }

        Scheduler.instance.fixedFrameEvent.addListener(weakOwner: self) { [weak self] delta in
            self?.fixedFrameUpdate(delta)
        }

        let sizeVec = self.size.asVector2D

        spawnCircles()

        #if true

        polys = [
            //Circle2Parametric(circle: .init(center: sizeVec / 2, radius: sizeVec.x / 5)),
            //LinePolygon2Parametric(location: sizeVec * .init(x: 0.4, y: 0.3), size: sizeVec * 0.5),
            //RoundedRectPoly(location: sizeVec * .init(x: 0.2, y: 0.4), size: sizeVec * .init(x: 0.4, y: 0.3), radius: sizeVec.x * 0.05),
            //Circle2Parametric(circle: .init(center: .init(x: 407, y: 276), radius: sizeVec.x / 20)),
            //LinePolygon2Parametric(location: sizeVec * .init(x: 0.2, y: 0.4), size: sizeVec * .init(x: 0.4, y: 0.3)),
            //Circle2Parametric(circle: .init(center: .init(x: 385, y: 539), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 265, y: 525), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 200, y: 525), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 153, y: 441), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 248, y: 443), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 200, y: 470), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 376, y: 525), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 324, y: 575), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 306, y: 283), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 646, y: 337), radius: sizeVec.x / 20)),
            Circle2Parametric(circle: .init(center: .init(x: 355, y: 214), radius: sizeVec.x / 20)),
        ]
        mousePoly.circle2.radius = sizeVec.x / 20

        #else

        polys = [
            CirclePoly(circle: .init(center: sizeVec / 2, radius: sizeVec.x / 5)),
            //RectPoly(location: sizeVec * .init(x: 0.4, y: 0.3), size: sizeVec * 0.5),
            //RoundedRectPoly(location: sizeVec * .init(x: 0.2, y: 0.4), size: sizeVec * .init(x: 0.4, y: 0.3), radius: sizeVec.x * 0.05),
            //CirclePoly(circle: .init(center: .init(x: 407, y: 276), radius: sizeVec.x / 20)),
            RectPoly(location: sizeVec * .init(x: 0.2, y: 0.4), size: sizeVec * .init(x: 0.4, y: 0.3)),
            //CirclePoly(circle: .init(center: .init(x: 306, y: 283), radius: sizeVec.x / 20)),
            //CirclePoly(circle: .init(center: .init(x: 646, y: 337), radius: sizeVec.x / 20)),
        ]
        mousePoly.circle.radius = sizeVec.x / 20

        #endif

        rootView.addSubview(labelStackView)
        labelStackView.addArrangedSubview(intersectCountLabel)
        labelStackView.addArrangedSubview(mouseLocationLabel)
        labelStackView.layout.makeConstraints { make in
            make.top == rootView + 5
            make.left == rootView + 5
        }

        intersectCountLabel.text = "Total intersections: Computing..."
        mouseLocationLabel.text = "Mouse location: (0, 0)"
    }

    func spawnCircles() {
        circles.removeAll()

        let count = 0
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

    open func fixedFrameUpdate(_ interval: TimeInterval) {
        let increment: Double
        if isShiftHeld {
            increment = interval / 10
        } else {
            increment = interval
        }

        circles = circles.map { circle in
            circle.updating(
                increment,
                bounds: .init(location: .zero, size: self.size.asVector2D)
            )
        }

        strokeAnimation = (strokeAnimation + increment).clamp(min: 0.0, max: 1.0)

        invalidateScreen()
    }

    open override func mouseMoved(event: MouseEventArgs) {
        super.mouseMoved(event: event)

        mouseLocationLabel.text = "Mouse location: (\(event.location.x), \(event.location.y))"

        #if true
        mousePoly.circle2.center = event.location.asVector2D
        #else
        mousePoly.circle.center = event.location.asVector2D
        #endif
    }

    open override func mouseDown(event: MouseEventArgs) {
        super.mouseDown(event: event)

        if event.buttons == .left {
            isMouseDown = true
        }
    }

    open override func mouseUp(event: MouseEventArgs) {
        if event.buttons == .left {
            isMouseDown = false
        }
    }

    open override func keyDown(event: KeyEventArgs) {
        super.keyDown(event: event)

        guard !event.handled else {
            return
        }

        if event.keyCode == .r {
            strokeAnimation = 0.0
        }
        if event.keyCode == .shiftKey {
            isShiftHeld = true
        }
    }

    open override func keyUp(event: KeyEventArgs) {
        super.keyUp(event: event)

        guard !event.handled else {
            return
        }

        if event.keyCode == .shiftKey {
            isShiftHeld = false
        }
    }

    open override func render(renderer: any Renderer, renderScale: UIVector, clipRegion: any ClipRegionType) {
        super.render(renderer: renderer, renderScale: renderScale, clipRegion: clipRegion)

        let polys = effectivePolys()

        renderer.setStroke(
            .init(color: .black, width: 1, startCap: .round, endCap: .round, joinStyle: .round)
        )
        //render(polys: polys, renderer: renderer)

        renderer.setStroke(
            .init(color: .black, width: 5, startCap: .round, endCap: .round, joinStyle: .round)
        )
        //renderUnion(polys: polys, renderer: renderer)
        //renderSubtraction(polys: polys, renderer: renderer)
        renderXor(polys: polys, renderer: renderer)
        //renderIntersection(polys: polys, renderer: renderer)
        //testEllipseNormals(renderer: renderer)

        //renderIntersections(polys: polys, renderer: renderer)
    }

    func renderUnion(
        polys: [any ParametricClip2Geometry],
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }

        let base = union(tolerance: 1e-14, polys)

        render(poly: base, renderer: renderer)
    }

    func renderSubtraction(
        polys: [any ParametricClip2Geometry],
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }

        guard let first = polys.first else {
            return
        }

        let base = subtraction(tolerance: 1e-14, first, Array(polys.dropFirst()))

        render(poly: base, renderer: renderer)
    }

    func renderXor(
        polys: [any ParametricClip2Geometry],
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }

        let base = xor(tolerance: 1e-14, polys)

        render(poly: base, renderer: renderer)
    }

    func renderIntersection(
        polys: [any ParametricClip2Geometry],
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }

        let base = intersection(tolerance: 1e-14, polys)

        render(poly: base, renderer: renderer)
    }

    func renderIntersections(
        polys: [any ParametricClip2Geometry],
        renderer: any Renderer
    ) {
        /*
        func renderPoint(period: ParametricClip2Geometry.Period, on contour: Parametric2Contour<Vector2D>, color: Color) {
            let point = contour.compute(at: period)
            self.renderPoint(point.asUIPoint, color: color, renderer: renderer)
        }
        func renderPoint(period: ParametricClip2Geometry.Period, on poly: ParametricClip2Geometry, color: Color) {
            for contour in poly.allContours() {
                renderPoint(period: period, on: contour, color: color)
            }
        }
        func renderPair(
            _ pair: (`self`: ParametricClip2Geometry.Period, other: ParametricClip2Geometry.Period),
            lhs: ParametricClip2Geometry,
            rhs: ParametricClip2Geometry
        ) {
            if pair.`self` < strokeAnimation && pair.other < strokeAnimation {
                renderPoint(period: pair.`self`, on: lhs, color: .red)
                renderPoint(period: pair.other, on: rhs, color: .blue)
            }
        }
        func renderPair(
            _ pair: ParametricClip2Intersection<Double>,
            lhs: ParametricClip2Geometry,
            rhs: ParametricClip2Geometry
        ) {
            for pair in pair.periods {
                renderPair(pair, lhs: lhs, rhs: rhs)
            }
        }

        var totalIntersections = 0

        for lhsIndex in 0..<(polys.count - 1) {
            let lhs = polys[lhsIndex]

            for rhsIndex in (lhsIndex + 1)..<polys.count {
                guard lhsIndex != rhsIndex else { continue }

                let rhs = polys[rhsIndex]

                let result = lhs.allIntersectionPeriods(rhs)

                totalIntersections += result.count

                for pair in result {
                    renderPair(pair, lhs: lhs, rhs: rhs)
                }
            }
        }

        intersectCountLabel.text = "Total intersections: \(totalIntersections)"
        */
    }

    /*
    func testEllipseNormals(renderer: any Renderer) {
        let sizeVec = self.size.asVector2D
        let ellipse = Ellipse2D(center: sizeVec / 2, radius: sizeVec * .init(x: 0.3, y: 0.2))
        renderer.stroke(ellipse.asUIEllipse)

        for angle in stride(from: 0, to: .pi * 2, by: .pi * 2 / 100.0) {
            let ellipsePoint = ellipse.center + Vector2D(
                x: cos(angle),
                y: sin(angle)
            ) * ellipse.radius

            let toCenter = (ellipsePoint - ellipse.center).normalized()

            let lineStart = ellipsePoint - toCenter * 5
            let lineEnd = ellipsePoint + toCenter * 5

            let line = LineSegment2D(start: lineStart, end: lineEnd)

            switch ellipse.intersection(with: line) {
            case .noIntersection, .contained:
                break

            case .singlePoint(let pn), .enter(let pn), .exit(let pn), .enterExit(let pn, _):
                let magnitudeStart = 5.0
                let magnitudeEnd = 105.0
                let intersectLine = LineSegment2D(
                    start: pn.point - pn.normal * magnitudeStart,
                    end: pn.point + pn.normal * magnitudeEnd
                )

                renderer.stroke(intersectLine.asUILine)
            }
        }
    }
    */

    func render(polys: [any ParametricClip2Geometry], renderer: any Renderer) {
        for poly in polys {
            render(poly: poly, renderer: renderer)
        }
    }

    func render(poly: any ParametricClip2Geometry, renderer: any Renderer) {
        for contour in poly.allContours() {
            render(contour: contour, renderer: renderer)
        }
    }

    func render(contour: Parametric2Contour<Vector2D>, renderer: any Renderer) {
        let simplexes = contour.clampedSimplexes(in: 0..<strokeAnimation)
        let actual = contour.compute(at: strokeAnimation).asUIPoint

        render(ops: simplexes, renderer: renderer)
        renderPoint(actual, color: .green, renderer: renderer)
    }

    func render(ops: [Parametric2GeometrySimplex<Vector2D>], renderer: any Renderer) {
        for op in ops {
            render(op: op, renderer: renderer)
        }
    }

    func render(op: Parametric2GeometrySimplex<Vector2D>, renderer: any Renderer) {
        switch op {
        case .lineSegment2(let lineSegment2):
            render(op: lineSegment2, renderer: renderer)

        case .circleArc2(let circleArc2):
            render(op: circleArc2, renderer: renderer)
        }
    }

    func render(op: LineSegment2Simplex<Vector2D>, renderer: any Renderer) {
        let line = op.lineSegment.asUILine

        renderer.stroke(line)
    }

    func render(op: CircleArc2Simplex<Vector2D>, renderer: any Renderer) {
        let arc = op.circleArc.asUICircleArc

        renderer.stroke(arc)
    }

    func renderPoint(_ point: UIPoint, color: Color, renderer: any Renderer) {
        let circle = UICircle(center: point, radius: 5)
        renderer.setFill(color)
        renderer.fill(circle)
    }

    struct DemoCircle {
        var circle: Circle2Parametric
        var velocity: Vector2D

        func makeHollow() -> Compound2Parametric {
            var inner = circle.reversed()
            inner.circle2.radius *= 0.8

            return Compound2Parametric(contours:
                circle.allContours() + inner.allContours()
            )
        }

        func updating(_ dt: TimeInterval, bounds: AABB2D) -> Self {
            var copy = self
            copy.update(dt, bounds: bounds)
            return copy
        }

        mutating func update(_ dt: TimeInterval, bounds: AABB2D) {
            // Make sure we can travel before updating the positions
            guard circle.circle2.radius < bounds.width && circle.circle2.radius < bounds.height else {
                return
            }

            circle.circle2.center += velocity * dt
            let circleBounds = circle.circle2.bounds

            if circleBounds.left <= bounds.minimum.x {
                velocity.x = velocity.x.magnitude
            } else if circleBounds.right >= bounds.maximum.x {
                velocity.x = -(velocity.x.magnitude)
            }
            if circleBounds.top < bounds.minimum.y {
                velocity.y = velocity.y.magnitude
            } else if circleBounds.bottom >= bounds.maximum.y {
                velocity.y = -(velocity.y.magnitude)
            }
        }
    }
}
