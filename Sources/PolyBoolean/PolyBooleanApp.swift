import Foundation
import ImagineUI
import SwiftBlend2D
import Geometria
import GeometriaClipping

open class PolyBooleanApp: ImagineUIWindowContent {
    var _updateTimer: SchedulerTimerType?

    var isMouseDown: Bool = false
    var isShiftHeld: Bool = false

    #if true

    var polys: [any ParametricClip2Geometry] = []
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
            return polys + [mousePoly]
        }

        return polys
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

        #if true

        polys = [
            Circle2Parametric(circle: .init(center: sizeVec / 2, radius: sizeVec.x / 5)),
            //LinePolygon2Parametric(location: sizeVec * .init(x: 0.4, y: 0.3), size: sizeVec * 0.5),
            //RoundedRectPoly(location: sizeVec * .init(x: 0.2, y: 0.4), size: sizeVec * .init(x: 0.4, y: 0.3), radius: sizeVec.x * 0.05),
            //Circle2Parametric(circle: .init(center: .init(x: 407, y: 276), radius: sizeVec.x / 20)),
            LinePolygon2Parametric(location: sizeVec * .init(x: 0.2, y: 0.4), size: sizeVec * .init(x: 0.4, y: 0.3)),
            //Circle2Parametric(circle: .init(center: .init(x: 385, y: 539), radius: sizeVec.x / 20)),
            Circle2Parametric(circle: .init(center: .init(x: 265, y: 525), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 324, y: 575), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 306, y: 283), radius: sizeVec.x / 20)),
            //Circle2Parametric(circle: .init(center: .init(x: 646, y: 337), radius: sizeVec.x / 20)),
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

    open override func mouseMoved(event: MouseEventArgs) {
        super.mouseMoved(event: event)

        mouseLocationLabel.text = "Mouse location: (\(event.location.x), \(event.location.y))"

        #if true
        mousePoly.circle2.center = event.location.asVector2D
        #else
        mousePoly.circle.center = event.location.asVector2D
        #endif

        invalidateScreen()
    }

    open override func mouseDown(event: MouseEventArgs) {
        super.mouseDown(event: event)

        if event.buttons == .left {
            isMouseDown = true
            invalidateScreen()
        }
    }

    open override func mouseUp(event: MouseEventArgs) {
        if event.buttons == .left {
            isMouseDown = false
            invalidateScreen()
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

    var strokeAnimation: Double = 0 {
        didSet {
            if strokeAnimation != oldValue {
                invalidateScreen()
            }
        }
    }
    open func fixedFrameUpdate(_ interval: TimeInterval) {
        let increment: Double
        if isShiftHeld {
            increment = interval / 10
        } else {
            increment = interval
        }

        strokeAnimation += increment
        strokeAnimation = strokeAnimation.clamp(min: 0.0, max: 1.0)
    }

    open override func render(renderer: any Renderer, renderScale: UIVector, clipRegion: any ClipRegionType) {
        super.render(renderer: renderer, renderScale: renderScale, clipRegion: clipRegion)

        let polys = effectivePolys()

        renderer.setStroke(
            .init(color: .black, width: 1, startCap: .round, endCap: .round, joinStyle: .round)
        )
        render(polys: polys, renderer: renderer)

        renderer.setStroke(
            .init(color: .black, width: 5, startCap: .round, endCap: .round, joinStyle: .round)
        )
        renderUnion(polys: polys, renderer: renderer)
        //renderIntersections(polys: polys, renderer: renderer)
        //testEllipseNormals(renderer: renderer)
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

        var remaining: [any ParametricClip2Geometry] = polys

        var hasMerged: Bool
        repeat {
            guard remaining.count > 1 else {
                break
            }
            hasMerged = false

            outer:
            for (index, current) in remaining.enumerated() {
                for (nextIndex, next) in remaining.enumerated().dropFirst(index + 1) {
                    guard index != nextIndex else { continue }
                    guard current.bounds.intersects(next.bounds) else { continue }

                    let op = Union2Parametric(current, next, tolerance: 1e-14)
                    let union = op.allSimplexes()

                    guard union.count != 2 else {
                        continue
                    }

                    // Union ocurred
                    remaining.remove(at: nextIndex)
                    remaining.remove(at: index)

                    for shape in union {
                        remaining.append(
                            Compound2Parametric(simplexes: shape)
                        )
                    }

                    hasMerged = true
                    break outer
                }
            }
        } while hasMerged

        render(polys: remaining, renderer: renderer)
    }

    func renderIntersections(
        polys: [any ParametricClip2Geometry],
        renderer: any Renderer
    ) {
        func renderPoint(period: ParametricClip2Geometry.Period, on poly: ParametricClip2Geometry, color: Color) {
            let point = poly.compute(at: period)
            self.renderPoint(point.asUIPoint, color: color, renderer: renderer)
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
            _ pair: ParametricClip2Intersection,
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
        let simplexes = poly.clampedSimplexes(in: 0..<strokeAnimation)
        let actual = poly.compute(at: strokeAnimation).asUIPoint

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
}
