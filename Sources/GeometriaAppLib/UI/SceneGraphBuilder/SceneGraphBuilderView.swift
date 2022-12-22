import ImagineUI

class SceneGraphBuilderView: RootView {
    private var _sidePanel: SidePanel = SidePanel(pinSide: .left, length: 250)
    private var _nodesContainer: SceneGraphBuilderNodeContainer = SceneGraphBuilderNodeContainer()
    private var _connectionViewsManager: ConnectionViewsManager

    /// - note: Must be ordered in the same order as they are rendered on screen.
    private var _nodeViews: [SceneGraphNodeView] = []
    private var _connections: [ConnectionViewInfo] = [] {
        didSet {
            _updateConnectionElements()
        }
    }

    weak var delegate: SceneGraphBuilderViewDelegate?

    override init() {
        _connectionViewsManager = .init(container: _nodesContainer)

        super.init()

        initialize()
    }

    private func initialize() {
        cacheAsBitmap = false

        backColor = Color(red: 37, green: 37, blue: 38)
    }

    override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_nodesContainer)
        addSubview(_sidePanel)
    }

    override func setupConstraints() {
        super.setupConstraints()

        _nodesContainer.layout.makeConstraints { layout in
            layout.edges == self
        }
    }

    override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if let mouseEvent = eventRequest as? MouseEventRequest, mouseEvent.eventType == MouseEventType.mouseWheel {
            return true
        }

        return super.canHandle(eventRequest)
    }

    @discardableResult
    private func _addNode(_ node: SceneGraphNode) -> SceneGraphNodeView {
        let view = SceneGraphNodeView(node: node)

        _nodesContainer.addSubview(view)
        _nodeViews.append(view)

        return view
    }

    @discardableResult
    private func _addEdge(_ edge: SceneGraphEdge) -> SceneGraphConnectionElement? {
        // Find end points to create connection view
        guard let startNode = _viewForNode(edge.start.sceneGraphNode) else {
            return nil
        }
        guard let endNode = _viewForNode(edge.end.sceneGraphNode) else {
            return nil
        }

        let startAnchor: SceneGraphConnectionElement.AnchorElement
        let endAnchor: SceneGraphConnectionElement.AnchorElement

        switch edge.start.element {
        case .node:
            return nil
        case .input(_, let input):
            startAnchor = .input(startNode, index: input.index)
        case .output(_, let output):
            startAnchor = .output(startNode, index: output.index)
        }

        switch edge.end.element {
        case .node:
            return nil
        case .input(_, let input):
            endAnchor = .input(endNode, index: input.index)
        case .output(_, let output):
            endAnchor = .output(endNode, index: output.index)
        }

        return _createConnectionElement(startAnchor: startAnchor, endAnchor: endAnchor)
    }

    private func _moveNodeViewToFront(_ nodeView: SceneGraphNodeView) {
        nodeView.bringToFrontOfSuperview()

        // Push it to the end of the node list array, as well, since we query
        // elements in that array in reverse order when looking for display
        // elements to select with the mouse
        if let index = _nodeViews.firstIndex(of: nodeView) {
            _nodeViews.remove(at: index)
            _nodeViews.append(nodeView)
        }

        _connectionViewsManager.updateZIndices(connectedTo: nodeView)
    }

    private func _removeNodeView(_ nodeView: SceneGraphNodeView) {
        guard let index = _nodeViews.firstIndex(of: nodeView) else { return }

        nodeView.removeFromSuperview()
        _nodeViews.remove(at: index)
    }

    private func _createConnectionElement(
        startAnchor: SceneGraphConnectionElement.AnchorElement? = nil,
        endAnchor: SceneGraphConnectionElement.AnchorElement? = nil
    ) -> SceneGraphConnectionElement {

        let element = SceneGraphConnectionElement(
            startAnchor: startAnchor,
            endAnchor: endAnchor
        )
        let info = ConnectionViewInfo(element: element)

        _connections.append(info)

        return element
    }

    private func _removeConnectionElement(_ element: SceneGraphConnectionElement) {
        _connections.removeAll { $0.element === element }
    }

    private func _updateConnectionElements() {
        _connectionViewsManager.updateConnectionViews(
            _connections,
            globalSpatialReference: self
        )
    }

    private func _openContextMenu(items: [ContextMenuItemEntry], location: UIPoint) {
        delegate?.openDialog(
            ContextMenuView.create(items: items),
            location: .topLeft(location)
        )
    }

    private func _nodeUnder(point: UIPoint) -> SceneGraphNodeView? {
        for node in _nodeViews.reversed() {
            let converted = node.convert(point: point, from: self)
            if node.contains(point: converted) {
                return node
            }
        }

        return nil
    }

    private func _elementUnder(point: UIPoint) -> SceneGraphMouseElementKind? {
        let iterator = _iteratorForElementsUnder(point: point)

        return iterator.next()
    }

    private func _allElementsUnder(point: UIPoint) -> [SceneGraphMouseElementKind] {
        let iterator = _iteratorForElementsUnder(point: point)
        
        return Array(iterator)
    }

    private func _iteratorForElementsUnder(point: UIPoint) -> AnyIterator<SceneGraphMouseElementKind> {
        let viewElements = _nodesContainer.subviews

        var viewIterator = viewElements.reversed().makeIterator()

        return AnyIterator {
            while let view = viewIterator.next() {
                let converted = view.convert(point: point, from: self)
                guard view.contains(point: converted) else {
                    continue
                }

                if let node = view as? SceneGraphNodeView {
                    // Check if mouse overlaps an input or output node
                    if let (view, input) = node.inputViewConnection(under: converted) {
                        return .input(view, input, node: node.node, node)
                    }
                    if let (view, output) = node.outputViewConnection(under: converted) {
                        return .output(view, output, node: node.node, node)
                    }

                    // If no inner overlap is found, return the node view itself.
                    return .node(node: node.node, node)
                }
                if let connection = view as? ConnectionView {
                    guard let edge = connection.graphEdge else {
                        continue
                    }

                    return .connection(connection.visualConnection, edge: edge)
                }
            }

            return nil
        }
    }

    private func _viewForNode(_ node: SceneGraphNode) -> SceneGraphNodeView? {
        _nodeViews.first { $0.node === node }
    }

    private class ConnectionViewsManager {
        private var connectionViews: [ConnectionView] = []

        let container: View

        init(container: View) {
            self.container = container
        }

        func updateZIndices(connectedTo nodeView: SceneGraphNodeView) {
            for view in connectionViews {
                guard view.visualConnection.isAssociatedWith(nodeView) else {
                    continue
                }

                view.bringInFrontOfSiblingView(nodeView)
            }
        }

        func updateConnectionViews(
            _ infoList: [ConnectionViewInfo],
            globalSpatialReference: SpatialReferenceType
        ) {

            var oldViews = connectionViews

            for info in infoList {
                oldViews.removeAll(where: { $0.visualConnection === info.element })

                self._createOrUpdate(
                    info,
                    globalSpatialReference: globalSpatialReference
                )
            }

            for old in oldViews {
                old.removeFromSuperview()
            }
        }

        @discardableResult
        private func _createOrUpdate(
            _ info: ConnectionViewInfo,
            globalSpatialReference: SpatialReferenceType
        ) -> ConnectionView? {

            let connection = info.element
            
            for existing in connectionViews {
                if existing.visualConnection === connection {
                    existing.updateConnectionView(
                        globalSpatialReference: globalSpatialReference
                    )
                    existing.graphEdge = info.graphEdge

                    return existing
                }
            }

            let view = ConnectionView(visualConnection: connection)
            view.updateConnectionView(
                globalSpatialReference: globalSpatialReference
            )
            view.graphEdge = info.graphEdge
            
            connectionViews.append(view)
            container.addSubview(view)

            return view
        }
    }

    private class ConnectionView: ControlView {
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
            if let state {
                renderer.setStroke(.orange)
                renderer.setStrokeWidth(_stokeWidth * strokeScale)

                renderer.stroke(state.bezier)
            }
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

            let start = computeAnchorPoint(
                startAnchor,
                globalSpatialReference: globalSpatialReference
            )
            let end = computeAnchorPoint(
                endAnchor,
                globalSpatialReference: globalSpatialReference
            )

            // Create bezier for the points now
            let hSeparation = (end.x - start.x) * 0.75
            let startOffset = UIPoint(x: hSeparation, y: 0)
            let endOffset = -UIPoint(x: hSeparation, y: 0)

            let p0 = start
            let p1 = start + startOffset
            let p2 = end + endOffset
            let p3 = end

            var bezier = UIBezier()
            bezier.move(to: p0)
            bezier.cubic(to: p3, p1: p1, p2: p2)

            return bezier
        }

        private func computeAnchorPoint(
            _ anchor: SceneGraphConnectionElement.AnchorElement,
            globalSpatialReference: SpatialReferenceType
        ) -> UIPoint {

            func forViewCenter(_ view: View) -> UIPoint {
                let center = view.bounds.center

                return self.convert(point: center, from: view)
            }
            func forViewRight(_ view: View) -> UIPoint {
                let point =
                    view.bounds.center
                    + UIPoint(x: view.size.width / 2, y: 0)

                return self.convert(point: point, from: view)
            }
            func forViewLeft(_ view: View) -> UIPoint {
                let point =
                    view.bounds.center
                    - UIPoint(x: view.size.width / 2, y: 0)

                return self.convert(point: point, from: view)
            }

            switch anchor {
            case .input(let nodeView, let index):
                let (view, _) = nodeView.inputViewConnection(forInputIndex: index)
                return forViewLeft(view)

            case .output(let nodeView, let index):
                let (view, _) = nodeView.outputViewConnection(forOutputIndex: index)
                return forViewRight(view)

            case .view(let view, let localOffset):
                return self.convert(point: localOffset, from: view)

            case .globalLocation(let point):
                return globalSpatialReference.convert(point: point, to: self)
            }
        }

        private class _State {
            var bezier: UIBezier

            init(bezier: UIBezier) {
                self.bezier = bezier
            }
        }
    }

    private struct ConnectionViewInfo {
        var element: SceneGraphConnectionElement
        var graphEdge: SceneGraphEdge?
    }
}

extension SceneGraphBuilderView: SceneGraphBuilderControllerUIDelegate {
    // MARK: - Querying
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        nodeUnder point: UIPoint
    ) -> SceneGraphNodeView? {

        _nodeUnder(point: point)
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        viewForGraphNode node: SceneGraphNode
    ) -> SceneGraphNodeView? {

        return _nodeViews.first { $0.node === node }
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        elementUnder point: UIPoint
    ) -> SceneGraphMouseElementKind? {

        _elementUnder(point: point)
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        allElementsUnder point: UIPoint
    ) -> [SceneGraphMouseElementKind] {

        _allElementsUnder(point: point)
    }

    func sceneGraphBuilderControllerNodesContainer(
        _ controller: SceneGraphBuilderController
    ) -> SceneGraphBuilderNodeContainer {

        _nodesContainer
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        convertPoint point: UIPoint,
        from reference: SpatialReferenceType?
    ) -> UIPoint {

        self.convert(point: point, from: reference)
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        convertPoint point: UIPoint,
        to reference: SpatialReferenceType?
    ) -> UIPoint {

        self.convert(point: point, to: reference)
    }

    // MARK: - Manipulating

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        createViewForNode node: SceneGraphNode
    ) -> SceneGraphNodeView {

        _addNode(node)
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        createViewForEdge edge: SceneGraphEdge
    ) {

        _addEdge(edge)
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        translateViewportToLocation location: UIPoint
    ) {

        _nodesContainer.translation = location
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        zoomViewportBy zoom: Double
    ) {
        
        let newZoom = _nodesContainer.zoom + zoom
        let clampedZoom = min(max(newZoom, 0.25), 2.0)

        _nodesContainer.zoom = clampedZoom
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        moveView view: View,
        toLocation location: UIPoint
    ) {
        
        view.location = location

        if view is SceneGraphNodeView {
            _updateConnectionElements()
        }
    }

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        bringNodeViewToFront nodeView: SceneGraphNodeView
    ) {

        _moveNodeViewToFront(nodeView)
    }

    /// Requests that a new connection element be created and added to the
    /// interface.
    func sceneGraphBuilderControllerCreateConnectionElement(
        _ controller: SceneGraphBuilderController
    ) -> SceneGraphConnectionElement {

        return _createConnectionElement()
    }

    /// Requests that a connection element be removed from the interface.
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        removeConnectionElement element: SceneGraphConnectionElement
    ) {

        _removeConnectionElement(element)
    }

    /// Updates the starting anchor for a connection element.
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        updateStartAnchorFor element: SceneGraphConnectionElement,
        _ anchor: SceneGraphConnectionElement.AnchorElement?
    ) {

        element.startAnchor = anchor

        _updateConnectionElements()
    }

    /// Updates the ending anchor for a connection element.
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        updateEndAnchorFor element: SceneGraphConnectionElement,
        _ anchor: SceneGraphConnectionElement.AnchorElement?
    ) {

        element.endAnchor = anchor

        _updateConnectionElements()
    }

    // MARK: - UI components

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        openContextMenu items: [ContextMenuItemEntry],
        location: UIPoint
    ) {

        self._openContextMenu(items: items, location: location)
    }
}

protocol SceneGraphBuilderViewDelegate: AnyObject {
    /// Request that the UI open a view as a dialog, obscuring the underlying
    /// views while the view is displayed.
    ///
    /// Returns a boolean value indicating whether the view was successfully opened.
    @discardableResult
    func openDialog(_ view: UIDialog, location: UIDialogInitialLocation) -> Bool
}
