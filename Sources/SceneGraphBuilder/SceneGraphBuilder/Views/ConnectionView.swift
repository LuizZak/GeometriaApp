import ImagineUI

class ConnectionView: ControlView {
    private var _stokeWidth: Double = 2.0
    private var _boundsForRedraw: UIRectangle = .zero
    private var state: _State?

    let visualConnection: SceneGraphConnectionElement

    /// An associated scene graph edge for this connection, if it represents
    /// one.
    var graphEdge: SceneGraphEdge?

    var strokeScale = 1.0 {
        didSet {
            invalidate()
        }
    }

    init(visualConnection: SceneGraphConnectionElement) {
        self.visualConnection = visualConnection

        super.init()

        clipToBounds = false
    }

    override func renderForeground(in renderer: Renderer, screenRegion: ClipRegionType) {
        guard let state else {
            return
        }

        let finalStrokeWidth = _stokeWidth * strokeScale

        // Stroke shadow
        renderer.setStrokeWidth(finalStrokeWidth + 2)
        renderer.setStroke(.black.withTransparency(factor: 0.6))
        renderer.stroke(state.bezier)

        renderer.setStrokeWidth(finalStrokeWidth)
        renderer.setStroke(.orange)
        renderer.stroke(state.bezier)
    }

    override func boundsForRedraw() -> UIRectangle {
        _boundsForRedraw
    }

    override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if let mouseEvent = eventRequest as? MouseEventRequest {
            switch mouseEvent.eventType {
            case .mouseDown, .mouseUp, .mouseClick, .mouseDoubleClick:
                return false
            default:
                break
            }
        }

        return super.canHandle(eventRequest)
    }

    func updateConnectionView(globalSpatialReference: SpatialReferenceType) {
        _invalidateBezierArea()

        let newState = self._createOrUpdateState(
            globalSpatialReference: globalSpatialReference
        )

        state = newState

        _invalidateBezierArea()
    }

    private func _createOrUpdateState(
        globalSpatialReference: SpatialReferenceType
    ) -> _State? {

        guard let bezier = makeBezier(
            globalSpatialReference: globalSpatialReference
        ) else {
            visualConnection.bezier = nil
            return nil
        }

        visualConnection.bezier = bezier
        
        if let state {
            state.bezier = bezier

            return state
        }

        return _State(bezier: bezier)
    }

    override func onStateChanged(_ change: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(change)

        updateColors()
    }

    override func contains(point: UIVector, inflatingArea: UIVector = .zero) -> Bool {
        if let state {
            return state.bezier.distance(to: point) < 5
        }

        return false
    }

    override func intersects(area: UIRectangle, inflatingArea: UIVector = .zero) -> Bool {
        _boundsForRedraw
            .insetBy(x: -inflatingArea.x, y: -inflatingArea.y)
            .intersects(area)
    }

    private func updateColors() {
        switch controlState {
        case .normal:
            strokeScale = 1
        case .highlighted:
            strokeScale = 2
        default:
            break
        }
    }

    private func _invalidateBezierArea() {
        if let state {
            var area = state.bezier.bounds()
            area = area.inflatedBy(_stokeWidth * strokeScale * 2)

            invalidate(bounds: area)

            _boundsForRedraw = area
            bounds = _boundsForRedraw
        } else {
            _boundsForRedraw = .zero
            bounds = .zero
        }
    }

    private func makeBezier(
        globalSpatialReference: SpatialReferenceType
    ) -> UIBezier? {

        guard let startAnchor = visualConnection.startAnchor else {
            return nil
        }
        guard let endAnchor = visualConnection.endAnchor else {
            return nil
        }

        let startInfo = computeAnchorPoint(
            startAnchor,
            globalSpatialReference: globalSpatialReference
        )
        let endInfo = computeAnchorPoint(
            endAnchor,
            globalSpatialReference: globalSpatialReference
        )

        let startPoint = startInfo.point
        let endPoint = endInfo.point

        // Create bezier for the points now
        let p0 = startPoint
        let p1 = startInfo.bezierAnchorPoint(endInfo)
        let p2 = endInfo.bezierAnchorPoint(startInfo)
        let p3 = endPoint

        var bezier = UIBezier()
        bezier.move(to: p0)
        bezier.cubic(to: p3, p1: p1, p2: p2)

        return bezier
    }

    private func computeAnchorPoint(
        _ anchor: SceneGraphConnectionElement.AnchorElement,
        globalSpatialReference: SpatialReferenceType
    ) -> AnchorPointInfo {

        func forViewCenter(_ view: View) -> UIPoint {
            let center = view.bounds.center

            return self.convert(point: center, from: view)
        }
        func forViewRight(_ view: View) -> UIPoint {
            let point = view.bounds.center
                + UIPoint(x: view.size.width / 2, y: 0)

            return self.convert(point: point, from: view)
        }
        func forViewLeft(_ view: View) -> UIPoint {
            let point = view.bounds.center
                - UIPoint(x: view.size.width / 2, y: 0)

            return self.convert(point: point, from: view)
        }

        switch anchor {
        case .input(_, let info):
            let point = forViewLeft(info.connectionView)

            return .init(point: point, direction: .left)

        case .output(_, let info):
            let point = forViewRight(info.connectionView)

            return .init(point: point, direction: .right)

        case .view(let view, let localOffset):
            let point = self.convert(point: localOffset, from: view)

            return .init(point: point)

        case .globalLocation(let point):
            let point = globalSpatialReference.convert(point: point, to: self)

            return .init(point: point)
        }
    }

    private class _State {
        var bezier: UIBezier

        init(bezier: UIBezier) {
            self.bezier = bezier
        }
    }

    private struct AnchorPointInfo {
        var point: UIPoint
        var direction: Direction = .none

        func bezierAnchorDistance(_ other: AnchorPointInfo) -> Double {
            let sep = other.point.x - self.point.x

            let minSep = 5.0

            let sx = self.point.x
            let ox = other.point.x

            switch (self.direction, other.direction) {
            case (.right, _) where sx + minSep > ox:
                return minSep

            case (.left, _) where sx - minSep < ox:
                return -minSep

            case (.right, _):
                return sep.magnitude / 2
            case (.left, _):
                return -sep.magnitude / 2
            
            case (.none, _):
                return sep
            }
        }

        func bezierAnchorPoint(_ other: AnchorPointInfo) -> UIPoint {
            let sep = bezierAnchorDistance(other)
            
            return UIPoint(x: point.x + sep, y: point.y)
        }

        enum Direction {
            case none
            case left
            case right
        }
    }
}
