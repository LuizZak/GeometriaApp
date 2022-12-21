import ImagineUI

class SceneGraphBuilderView: RootView {
    private var _sidePanel: SidePanel = SidePanel(pinSide: .left, length: 250)
    private var _nodesContainer: SceneGraphBuilderNodeContainer = SceneGraphBuilderNodeContainer()
    private var _nodeViews: [SceneGraphNodeView] = []

    weak var delegate: SceneGraphBuilderViewDelegate?

    override init() {
        super.init()

        initialize()
    }

    private func initialize() {
        cacheAsBitmap = false

        backColor = Color(red: 37, green: 37, blue: 38)

        let node1 = AABBGraphNode(aabb: .init(minimum: .zero, maximum: .one), material: .defaultMaterial)
        _addNode(node1).location = .init(x: 300, y: 100)
        let node2 = RaymarchingSceneNode()
        _addNode(node2).location = .init(x: 350, y: 200)
        let node3 = RaymarcherNode()
        _addNode(node3).location = .init(x: 550, y: 210)
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

    private func _removeNodeView(_ view: SceneGraphNodeView) {
        guard let index = _nodeViews.firstIndex(of: view) else { return }

        view.removeFromSuperview()
        _nodeViews.remove(at: index)
    }

    private func _openContextMenu(for view: SceneGraphNodeView, location: UIPoint) {
        delegate?.openDialog(
            ContextMenuView.create {
                ContextMenuItem(title: "Delete") {
                    self._removeNodeView(view)
                }
            },
            location: .topLeft(location)
        )
    }

    private func _nodeUnder(point: UIPoint) -> SceneGraphNodeView? {
        for node in _nodeViews {
            let converted = node.convert(point: point, from: self)
            if node.contains(point: converted) {
                return node
            }
        }

        return nil
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
    }

    // MARK: - UI components

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        openContextMenuFor view: SceneGraphNodeView,
        location: UIPoint
    ) {

        self._openContextMenu(for: view, location: location)
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
