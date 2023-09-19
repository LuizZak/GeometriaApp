import ImagineUI
import GeometriaAppLib

class SceneGraphBuilderView: RootView {
    private var _sidePanel: SidePanel = SidePanel(pinSide: .left, length: 250)
    private var _nodesContainer: SceneGraphBuilderNodeContainer = SceneGraphBuilderNodeContainer()
    private var _connectionViewsManager: ConnectionViewsManager

    private var _nodeListView: SceneGraphNodeListView = .init()

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

        _sidePanel.addSubview(_nodeListView)
    }

    override func setupConstraints() {
        super.setupConstraints()

        _nodesContainer.layout.makeConstraints { layout in
            layout.edges == self
        }

        _nodeListView.layout.makeConstraints { layout in
            layout.edges == _nodesContainer
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

        func anchorForElement(
            _ nodeView: SceneGraphNodeView,
            _ element: SceneGraphDirectedNodeElement.Element
        ) -> SceneGraphConnectionElement.AnchorElement? {

            switch element {
            case .node:
                return nil
            case .input(_, let input):
                let info = nodeView.inputViewConnection(forInputIndex: input.index)
                return .input(nodeView, info)

            case .output(_, let output):
                let info = nodeView.outputViewConnection(forOutputIndex: output.index)
                return .output(nodeView, info)
            }
        }

        guard let startAnchor = anchorForElement(startNode, edge.start.element) else {
            return nil
        }
        guard let endAnchor = anchorForElement(endNode, edge.end.element) else {
            return nil
        }

        _incrementConnectionCount(startAnchor)
        _incrementConnectionCount(endAnchor)

        return _createConnectionElement(
            startAnchor: startAnchor,
            endAnchor: endAnchor,
            graphEdge: edge
        )
    }

    private func _incrementConnectionCount(_ anchor: SceneGraphConnectionElement.AnchorElement) {
        anchor.inputViewInfo?.state.connectionAdded()
        anchor.outputViewInfo?.state.connectionAdded()
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

    private func _moveConnectionViewToFront(_ element: SceneGraphConnectionElement) {
        if let startNode = _nodeViewForStartAnchor(element) {
            startNode.bringToFrontOfSuperview()

            _connectionViewsManager.updateZIndices(connectedTo: startNode)
        }
        if let endNode = _nodeViewForEndAnchor(element) {
            endNode.bringToFrontOfSuperview()

            _connectionViewsManager.updateZIndices(connectedTo: endNode)
        }
    }
    
    private func _removeNodeView(_ nodeView: SceneGraphNodeView) {
        guard let index = _nodeViews.firstIndex(of: nodeView) else { return }

        nodeView.removeFromSuperview()
        _nodeViews.remove(at: index)
    }

    private func _createConnectionElement(
        startAnchor: SceneGraphConnectionElement.AnchorElement? = nil,
        endAnchor: SceneGraphConnectionElement.AnchorElement? = nil,
        graphEdge: SceneGraphEdge? = nil
    ) -> SceneGraphConnectionElement {

        let element = SceneGraphConnectionElement(
            startAnchor: startAnchor,
            endAnchor: endAnchor
        )
        let info = ConnectionViewInfo(element: element, graphEdge: graphEdge)

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
                    if let info = node.inputViewConnection(under: converted) {
                        return .input(info, node: node.node, node)
                    }
                    if let info = node.outputViewConnection(under: converted) {
                        return .output(info, node: node.node, node)
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

    private func _nodeViewForStartAnchor(_ element: SceneGraphConnectionElement) -> SceneGraphNodeView? {
        switch element.startAnchor {
        case nil:
            return nil
        case .input(let view, _), .output(let view, _):
            return view
        case .view(let view, _):
            return view as? SceneGraphNodeView
        case .globalLocation:
            return nil
        }
    }

    private func _nodeViewForEndAnchor(_ element: SceneGraphConnectionElement) -> SceneGraphNodeView? {
        switch element.endAnchor {
        case nil:
            return nil
        case .input(let view, _), .output(let view, _):
            return view
        case .view(let view, _):
            return view as? SceneGraphNodeView
        case .globalLocation:
            return nil
        }
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

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        bringEdgeToFront element: SceneGraphConnectionElement
    ) {

        _moveConnectionViewToFront(element)
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



    func sceneGraphBuilderBeginCustomTooltipLifetime(
        _ controller: SceneGraphBuilderController
    ) -> CustomTooltipHandlerType? {
        delegate?.beginCustomTooltipLifetime()
    }
}

protocol SceneGraphBuilderViewDelegate: RaytracerUIComponentDelegate {
    
}
