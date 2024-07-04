import Foundation
import ImagineUI
import SwiftBlend2D
import Geometria

open class PolyBooleanApp: ImagineUIWindowContent {
    var _updateTimer: SchedulerTimerType?

    var isMouseDown: Bool = false
    var isShiftHeld: Bool = false

    var polys: [any PolyBooleanType] = []
    var mousePoly: CirclePoly = .init(circle: .unit)

    let labelStackView = StackView(orientation: .vertical)
    let intersectCountLabel = Label(textColor: .black, fontSize: 20)
    let mouseLocationLabel = Label(textColor: .black, fontSize: 20)

    func effectivePolys() -> [any PolyBooleanType] {
        if isMouseDown {
            return polys + [mousePoly]
        }

        return polys
    }

    open override func initialize() {
        super.initialize()

        _updateTimer = Scheduler.instance.scheduleTimer(interval: 1 / 60.0, repeats: true) { [weak self] in
            self?.update(UISettings.timeInSeconds())
        }

        Scheduler.instance.fixedFrameEvent.addListener(weakOwner: self) { [weak self] delta in
            self?.fixedFrameUpdate(delta)
        }

        let sizeVec = self.size.asVector2D

        polys = [
            //CirclePoly(circle: .init(center: sizeVec / 2, radius: sizeVec.x / 5)),
            RectPoly(location: sizeVec * .init(x: 0.4, y: 0.3), size: sizeVec * 0.5),
            //RoundedRectPoly(location: sizeVec * .init(x: 0.2, y: 0.4), size: sizeVec * .init(x: 0.4, y: 0.3), radius: sizeVec.x * 0.05),
            //CirclePoly(circle: .init(center: .init(x: 407, y: 276), radius: sizeVec.x / 20)),
            RectPoly(location: sizeVec * .init(x: 0.2, y: 0.4), size: sizeVec * .init(x: 0.4, y: 0.3)),
        ]
        mousePoly.circle.radius = sizeVec.x / 20

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
        mousePoly.circle.center = event.location.asVector2D

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

        renderer.setStroke(
            .init(color: .black, width: 5, startCap: .round, endCap: .round, joinStyle: .round)
        )

        let polys = effectivePolys()
        //render(polys: polys, renderer: renderer)
        renderUnion(polys: polys, renderer: renderer)
        //renderIntersections(polys: polys, renderer: renderer)
        //testEllipseNormals(renderer: renderer)
    }

    func renderUnion(
        polys: [any PolyBooleanType],
        renderer: any Renderer
    ) {
        if polys.isEmpty {
            return
        }
        if polys.count == 1 {
            render(poly: polys[0], renderer: renderer)
            return
        }

        let poly1 = polys[0]
        let poly2 = polys[1]

        let union = UnionBooleanOperation.union(poly1, poly2)

        render(strokes: union, renderer: renderer)
    }

    func renderIntersections(
        polys: [any PolyBooleanType],
        renderer: any Renderer
    ) {
        func renderPoint(period: PolyBooleanType.Period, on poly: PolyBooleanType, color: Color) {
            let point = poly.point(at: period)
            self.renderPoint(point.asUIPoint, color: color, renderer: renderer)
        }
        func renderPair(_ pair: PolyIntersectResult.Pair, lhs: PolyBooleanType, rhs: PolyBooleanType) {
            if pair.lhs.start < strokeAnimation && pair.rhs.start < strokeAnimation {
                renderPoint(period: pair.lhs.start, on: lhs, color: .red)
                renderPoint(period: pair.rhs.start, on: rhs, color: .blue)
            }
            if pair.lhs.end < strokeAnimation && pair.rhs.end < strokeAnimation {
                renderPoint(period: pair.lhs.end, on: lhs, color: .red)
                renderPoint(period: pair.rhs.end, on: rhs, color: .blue)
            }
        }

        var totalIntersections = 0

        let intersect = PolyIntersect()

        for lhsIndex in 0..<(polys.count - 1) {
            let lhs = polys[lhsIndex]

            for rhsIndex in (lhsIndex + 1)..<polys.count {
                guard lhsIndex != rhsIndex else { continue }

                let rhs = polys[rhsIndex]

                let result = intersect.intersect(lhs, rhs)

                totalIntersections += result.pairs.count * 2

                for pair in result.pairs {
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

    func render(polys: [any PolyBooleanType], renderer: any Renderer) {
        for poly in polys {
            render(poly: poly, renderer: renderer)
        }
    }

    func render(poly: some PolyBooleanType, renderer: any Renderer) {
        let stroke = poly.stroke(in: 0...strokeAnimation)
        let actual = poly.point(at: strokeAnimation).asUIPoint
        renderPoint(actual, color: .green, renderer: renderer)

        render(stroke: stroke, renderer: renderer)
    }

    func render(strokes: [PeriodicSurfaceStroke], renderer: any Renderer) {
        for stroke in strokes {
            render(stroke: stroke, renderer: renderer)
        }
    }

    func render(stroke: PeriodicSurfaceStroke, renderer: any Renderer) {
        render(op: stroke.op, renderer: renderer)
    }

    func render(ops: [PeriodicSurfaceStroke.Op], renderer: any Renderer) {
        for op in ops {
            render(op: op, renderer: renderer)
        }
    }

    func render(op: PeriodicSurfaceStroke.Op, renderer: any Renderer) {
        switch op {
        case .compound(let ops):
            render(ops: ops, renderer: renderer)

        case .line(let line):
            renderer.stroke(line)

        case .circleArc(let arc):
            renderer.stroke(arc)
        }
    }

    func renderPoint(_ point: UIPoint, color: Color, renderer: any Renderer) {
        let circle = UICircle(center: point, radius: 5)
        renderer.setFill(color)
        renderer.fill(circle)
    }
}
