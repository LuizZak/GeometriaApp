import Foundation
import ImagineUI
import GeometriaAppLib

/// Controls UI interactions with a scene graph builder interface.
class SceneGraphBuilderController {
    private var _mouseDownPoint: UIPoint = .zero
    private var _isMouseClickCandidate: Bool = false
    private var _mouseState: MouseState = .none
    private var _selection: [SceneGraphMouseElementKind] = []

    weak var uiDelegate: SceneGraphBuilderControllerUIDelegate?

    var sceneGraph: SceneGraph

    init() {
        self.sceneGraph = SceneGraph()
    }

    func initialize() {
        createMockGraph()
    }

    private func createMockGraph() {
        let node1 = AABBGraphNode(
            aabb: .init(minimum: .zero, maximum: .one),
            material: .defaultMaterial
        )
        let node2 = RaymarchingSceneNode()
        let node3 = RaymarcherNode()

        addNode(node1)?.location = .init(x: 300, y: 100)
        addNode(node2)?.location = .init(x: 350, y: 200)
        addNode(node3)?.location = .init(x: 550, y: 210)
    }

    // MARK: - Events - Mouse

    func onMouseDown(_ event: MouseEventArgs) {
        _mouseDownPoint = event.location
        _isMouseClickCandidate = true

        if event.buttons == .left {
            if let element = elementUnder(point: event.location) {
                switch element {
                case .node(_, let node):
                    beginNodeDrag(node, mouseLocation: event.location)

                case .input(let info, let node, _):
                    beginInputDrag(info, node: node)

                case .output(let info, let node, _):
                    beginOutputDrag(info, node: node)

                case .connection(let element, _, _):
                    uiDelegate?.sceneGraphBuilderController(
                        self,
                        bringEdgeToFront: element
                    )
                }
            } else {
                withNodeContainer { container in
                    _mouseState = .draggingViewport(initialOffset: event.location - container.translation)
                }
            }
        }
    }

    func onMouseMove(_ event: MouseEventArgs) {
        if event.location.distance(to: _mouseDownPoint) > 5 {
            _isMouseClickCandidate = false
        }

        updateDragState(event.location)
    }

    func onMouseUp(_ event: MouseEventArgs) {
        endDragState(event.location)
    }

    func onMouseClick(_ event: MouseEventArgs) {
        guard _isMouseClickCandidate else {
            return
        }

        switch event.buttons {
        case .left:
            clearSelection()

            guard let uiElement = elementUnder(point: event.location) else {
                break
            }

            addSelection(uiElement)

        case .right:
            guard let uiElement = elementUnder(point: event.location) else {
                break
            }

            openContextMenu(
                for: uiElement,
                location: convert(point: event.location, to: nil)
            )
        default:
            break
        }
    }

    func onMouseWheel(_ event: MouseEventArgs) {
        withNodeContainer { container in
            let zoom: Double

            if event.delta.y > 0 {
                zoom = 0.1
            } else if event.delta.y < 0 {
                zoom = -0.1
            } else {
                zoom = 0.0
            }

            if zoom != 0.0 {
                uiDelegate?.sceneGraphBuilderController(
                    self,
                    zoomViewportBy: zoom,
                    mouseLocation: event.location
                )
            }
        }
    }

    // MARK: Keyboard

    func onKeyDown(_ event: KeyEventArgs) {
    }

    func onKeyUp(_ event: KeyEventArgs) {
    }

    func onKeyPress(_ event: KeyPressEventArgs) {
    }

    // MARK: - Internals

    // MARK: Selection management

    private func clearSelection() {
        for selection in _selection {
            updateSelectionStatus(
                selection,
                isSelected: false
            )
        }

        _selection.removeAll()
    }

    private func addSelection(_ element: SceneGraphMouseElementKind) {
        guard !_selection.contains(where: { $0.associatedControlView === element.associatedControlView }) else {
            return
        }

        _selection.append(element)
        updateSelectionStatus(element, isSelected: true)
    }

    private func updateSelectionStatus(
        _ element: SceneGraphMouseElementKind,
        isSelected: Bool
    ) {
        element.associatedControlView.isSelected = isSelected
    }

    // MARK: Mouse state management

    private func beginNodeDrag(_ node: SceneGraphNodeView, mouseLocation: UIPoint) {
        uiDelegate?.sceneGraphBuilderController(
            self,
            bringNodeViewToFront: node
        )

        withNodeContainer { container in
            _mouseState = .draggingNode(
                ViewDragOperation(
                    view: node,
                    container: container,
                    offset: convert(point: mouseLocation, to: node)
                )
            )
        }
    }

    private func beginInputDrag(
        _ info: SceneGraphNodeView.InputViewInfo,
        node: SceneGraphNode
    ) {
        guard let uiDelegate else { return }
        guard let nodeView = uiDelegate.sceneGraphBuilderController(
            self, viewForGraphNode: node
        ) else { return }

        let connection = uiDelegate.sceneGraphBuilderControllerCreateConnectionElement(self)

        uiDelegate.sceneGraphBuilderController(
            self,
            updateStartAnchorFor: connection,
            .input(nodeView, info),
            isPreview: true
        )

        let operation = InputDragOperation(
            view: info.connectionView,
            input: info.input,
            node: node,
            connection: connection,
            tooltipHandler: beginCustomTooltipLifetime()
        )

        _mouseState = .draggingInput(operation)
    }

    private func beginOutputDrag(
        _ info: SceneGraphNodeView.OutputViewInfo,
        node: SceneGraphNode
    ) {
        guard let uiDelegate else { return }
        guard let nodeView = uiDelegate.sceneGraphBuilderController(
            self, viewForGraphNode: node
        ) else { return }

        let connection = uiDelegate.sceneGraphBuilderControllerCreateConnectionElement(self)
        uiDelegate.sceneGraphBuilderController(
            self,
            updateStartAnchorFor: connection,
            .output(nodeView, info),
            isPreview: true
        )

        let operation = OutputDragOperation(
            view: info.connectionView,
            output: info.output,
            node: node,
            connection: connection,
            tooltipHandler: beginCustomTooltipLifetime()
        )

        _mouseState = .draggingOutput(operation)
    }

    private func updateDragState(_ location: UIPoint) {
        guard let uiDelegate else { return }

        switch _mouseState {
        case .none:
            break

        case .draggingViewport(let offset):
            uiDelegate.sceneGraphBuilderController(
                self,
                translateViewportToLocation: location - offset
            )

        case .draggingNode(let operation):
            let point = convert(point: location, to: operation.container)

            uiDelegate.sceneGraphBuilderController(
                self,
                moveView: operation.view,
                toLocation: point - operation.offset
            )

        case .draggingInput(let operation):
            let endAnchor = operation.suggestedDragEndAnchor(
                mouseLocation: location,
                in: self
            )

            updateTooltipForConnectionAnchor(
                operation.tooltipHandler,
                operation.suggestedDragStartAnchor(),
                endAnchor
            )

            uiDelegate.sceneGraphBuilderController(
                self,
                updateEndAnchorFor: operation.connection,
                endAnchor,
                isPreview: true
            )

        case .draggingOutput(let operation):
            let endAnchor = operation.suggestedDragEndAnchor(
                mouseLocation: location,
                in: self
            )

            updateTooltipForConnectionAnchor(
                operation.tooltipHandler,
                operation.suggestedDragStartAnchor(),
                endAnchor
            )

            uiDelegate.sceneGraphBuilderController(
                self,
                updateEndAnchorFor: operation.connection,
                endAnchor,
                isPreview: true
            )
        }
    }

    private func endDragState(_ location: UIPoint) {
        defer { _mouseState = .none }

        guard let uiDelegate else { return }

        switch _mouseState {
        case .draggingInput(let operation):
            operation.tooltipHandler?.endTooltipLifetime()

            let endAnchor = operation.suggestedDragEndAnchor(
                mouseLocation: location,
                in: self
            )
            uiDelegate.sceneGraphBuilderController(
                self,
                updateEndAnchorFor: operation.connection,
                endAnchor,
                isPreview: false
            )

            commitConnectionElement(operation.connection)

        case .draggingOutput(let operation):
            operation.tooltipHandler?.endTooltipLifetime()

            let endAnchor = operation.suggestedDragEndAnchor(
                mouseLocation: location,
                in: self
            )
            uiDelegate.sceneGraphBuilderController(
                self,
                updateEndAnchorFor: operation.connection,
                endAnchor,
                isPreview: false
            )

            commitConnectionElement(operation.connection)

        default:
            break
        }
    }

    // MARK: Querying

    private func nodeUnder(point: UIPoint) -> SceneGraphNodeView? {
        guard let uiDelegate else { return nil }

        return uiDelegate.sceneGraphBuilderController(self, nodeUnder: point)
    }

    private func elementUnder(point: UIPoint) -> SceneGraphMouseElementKind? {
        guard let uiDelegate else { return nil }

        return uiDelegate.sceneGraphBuilderController(self, elementUnder: point)
    }

    private func allElementsUnder(point: UIPoint) -> [SceneGraphMouseElementKind] {
        guard let uiDelegate else { return [] }

        return uiDelegate.sceneGraphBuilderController(self, allElementsUnder: point)
    }

    private func withNodeContainer(_ closure: (SceneGraphBuilderNodeContainer) -> Void) {
        guard let uiDelegate else { return }

        let container = uiDelegate.sceneGraphBuilderControllerNodesContainer(self)

        closure(container)
    }

    private func convert(point: UIPoint, from reference: SpatialReferenceType?) -> UIPoint {
        guard let uiDelegate else { return point }

        return uiDelegate.sceneGraphBuilderController(self, convertPoint: point, from: reference)
    }

    private func convert(point: UIPoint, to reference: SpatialReferenceType?) -> UIPoint {
        guard let uiDelegate else { return point }

        return uiDelegate.sceneGraphBuilderController(self, convertPoint: point, to: reference)
    }

    private func getNodeAndInput(
        _ view: SceneGraphNodeView,
        index: Int
    ) -> (SceneGraphNode, SceneGraphNodeInput)? {

        let node = view.node
        guard node.inputs.indices.contains(index) else {
            return nil
        }

        return (node, node.inputs[index])
    }

    private func getNodeAndOutput(
        _ view: SceneGraphNodeView,
        index: Int
    ) -> (SceneGraphNode, SceneGraphNodeOutput)? {

        let node = view.node
        guard node.outputs.indices.contains(index) else {
            return nil
        }

        return (node, node.outputs[index])
    }

    // MARK: UI

    private func createNodeView(for node: SceneGraphNode) -> SceneGraphNodeView? {
        guard let uiDelegate else { return nil }

        return uiDelegate.sceneGraphBuilderController(
            self,
            createViewForNode: node
        )
    }

    private func nodeView(for node: SceneGraphNode) -> SceneGraphNodeView? {
        guard let uiDelegate else { return nil }

        return uiDelegate.sceneGraphBuilderController(
            self,
            viewForGraphNode: node
        )
    }

    private func openContextMenu(for element: SceneGraphMouseElementKind, location: UIPoint) {
        switch element {
        case .node(let node, let view):
            openContextMenu(for: view, node: node, location: location)



        default:
            break
        }
    }

    private func openContextMenu(for view: SceneGraphNodeView, node: SceneGraphNode, location: UIPoint) {
        guard let uiDelegate else { return }

        let items = ContextMenuView.createItems {
            ContextMenuItem(title: "Delete") {
                self.removeNode(node)
            }
        }

        uiDelegate.sceneGraphBuilderController(
            self,
            openContextMenu: items,
            location: location
        )
    }

    private func updateTooltipForConnectionAnchor(
        _ tooltipHandler: CustomTooltipHandlerType?,
        _ startAnchor: SceneGraphConnectionElement.AnchorElement?,
        _ anchor: SceneGraphConnectionElement.AnchorElement
    ) {

        switch anchor {
        case .input(_, let info):
            tooltipHandler?.showTooltip(for: info.tooltipProvider, location: .left)

        case .output(_, let info):
            tooltipHandler?.showTooltip(for: info.tooltipProvider, location: .right)

        case .globalLocation(let location):
            guard let tooltip = nodeCreationTooltip(startAnchor) else {
                return
            }
            guard let tooltipProvider = nodeCreationTooltipProvider(location, tooltip) else {
                return
            }

            tooltipHandler?.showTooltip(
                for: tooltipProvider,
                location: .followingMouse
            )

        default:
            tooltipHandler?.hideTooltip()
        }
    }

    private func nodeCreationTooltip(
        _ anchor: SceneGraphConnectionElement.AnchorElement?
    ) -> Tooltip? {
        guard let anchor else {
            return nil
        }

        switch anchor {
        case .input(_, let info):
            return formatTooltip("\(image: GraphBuilderIconLibrary.addIcon) \(dataType: info.input.type)...")

        case .output(_, let info):
            return formatTooltip("\(image: GraphBuilderIconLibrary.addIcon) \(dataType: info.output.type)...")

        default:
            return nil
        }
    }

    private func nodeCreationTooltipProvider(
        _ location: UIPoint,
        _ tooltip: Tooltip
    ) -> TooltipProvider? {
        guard let view = uiDelegate?.sceneGraphBuilderGlobalTooltipView(self) else {
            return nil
        }

        return NodeCreationTooltip(viewForTooltip: view, tooltip: tooltip)
    }

    private func showTooltip(
        _ tooltipHandler: CustomTooltipHandlerType?,
        _ provider: TooltipProvider,
        location: PreferredTooltipLocation?
    ) {

        tooltipHandler?.showTooltip(for: provider, location: location)
    }

    private func beginCustomTooltipLifetime() -> CustomTooltipHandlerType? {
        uiDelegate?.sceneGraphBuilderBeginCustomTooltipLifetime(
            self
        )
    }

    // MARK: - Types

    private enum MouseState {
        case none
        case draggingViewport(initialOffset: UIVector)
        case draggingNode(ViewDragOperation)
        case draggingInput(InputDragOperation)
        case draggingOutput(OutputDragOperation)
    }

    private struct NodeCreationTooltip: TooltipProvider {
        var viewForTooltip: View
        var tooltip: Tooltip? {
            didSet {
                _tooltipUpdated(tooltip)
            }
        }
        @Event
        var tooltipUpdated: EventSource<Tooltip?>
        var preferredTooltipLocation: PreferredTooltipLocation = .followingMouse
        var tooltipCondition: TooltipDisplayCondition = .always
        var tooltipDelay: TimeInterval? = 0
    }

    private struct ViewDragOperation {
        /// View being dragged.
        var view: View

        /// The container for the view being dragged, aka its `superview` at the
        /// time of drag operation creation.
        var container: View

        /// Offset from view's `location` that the drag occurs.
        var offset: UIVector
    }

    private struct InputDragOperation {
        /// The view that the input connection should start from.
        var view: View

        /// The scene graph input being dragged.
        var input: SceneGraphNodeInput

        /// The graph node the input belongs to.
        var node: SceneGraphNode

        /// The UI element representing the connection being dragged.
        var connection: SceneGraphConnectionElement

        /// For displaying custom tooltips as the user interacts with other
        /// UI elements while the dragging operation is ongoing.
        var tooltipHandler: CustomTooltipHandlerType?

        func suggestedDragStartAnchor() -> SceneGraphConnectionElement.AnchorElement? {
            connection.startAnchor
        }

        func suggestedDragEndAnchor(
            mouseLocation: UIPoint,
            in controller: SceneGraphBuilderController
        ) -> SceneGraphConnectionElement.AnchorElement {

            let elements = controller.allElementsUnder(point: mouseLocation)

            outerLoop:
            for element in elements {
                switch element {
                case .input:
                    break outerLoop

                case .node(let graphNode, let nodeView):
                    if let output = controller.suggestOutput(
                        start: graphNode,
                        end: node,
                        input: input
                    ) {
                        let info = nodeView.outputViewConnection(forOutputIndex: output.index)

                        return .output(nodeView, info)
                    }

                    break outerLoop

                case .output(let info, let graphNode, let nodeView):
                    if controller.canConnect(
                        start: graphNode,
                        output: info.output,
                        end: node,
                        input: input
                    ) {
                        return .output(nodeView, info)
                    }

                case .connection:
                    continue
                }
            }

            return .globalLocation(mouseLocation)
        }
    }

    private struct OutputDragOperation {
        /// The view that the output connection should start from.
        var view: View

        /// The scene graph output being dragged.
        var output: SceneGraphNodeOutput

        /// The graph node the output belongs to.
        var node: SceneGraphNode

        /// The UI element representing the connection being dragged.
        var connection: SceneGraphConnectionElement

        /// For displaying custom tooltips as the user interacts with other
        /// UI elements while the dragging operation is ongoing.
        var tooltipHandler: CustomTooltipHandlerType?

        func suggestedDragStartAnchor() -> SceneGraphConnectionElement.AnchorElement? {
            connection.startAnchor
        }

        func suggestedDragEndAnchor(
            mouseLocation: UIPoint,
            in controller: SceneGraphBuilderController
        ) -> SceneGraphConnectionElement.AnchorElement {

            let elements = controller.allElementsUnder(point: mouseLocation)

            outerLoop:
            for element in elements {
                switch element {
                case .node(let graphNode, let nodeView),
                    .output(_, let graphNode, let nodeView):

                    if let input = controller.suggestInput(
                        start: node,
                        output: output,
                        end: graphNode
                    ) {
                        let info = nodeView.inputViewConnection(forInputIndex: input.index)

                        return .input(nodeView, info)
                    }

                    break outerLoop

                case .input(let info, let graphNode, let nodeView):
                    if controller.canConnect(
                        start: node,
                        output: output,
                        end: graphNode,
                        input: info.input
                    ) {
                        return .input(nodeView, info)
                    }

                    break outerLoop

                case .connection:
                    continue
                }
            }

            return .globalLocation(mouseLocation)
        }
    }
}

// MARK: - Node management

extension SceneGraphBuilderController {
    @discardableResult
    func addNode(_ node: SceneGraphNode) -> SceneGraphNodeView? {
        sceneGraph.addNode(node)

        return createNodeView(for: node)
    }

    func removeNode(_ node: SceneGraphNode) {
        guard let uiDelegate else {
            return
        }
        guard sceneGraph.containsNode(node) else {
            return
        }

        uiDelegate.sceneGraphBuilderController(self, removeViewForNode: node)

        guard let edges = sceneGraph.removeNode(node)?.edges else {
            return
        }

        for edge in edges {
            uiDelegate.sceneGraphBuilderController(self, removeViewForEdge: edge)
        }
    }

    /// Returns whether a particular scene graph node can be removed from the
    /// graph.
    func canRemoveNode(_ node: SceneGraphNode) -> Bool {
        return true
    }
}

// MARK: - Node connections

extension SceneGraphBuilderController {
    /// Returns whether a particular scene graph edge can be removed from the
    /// graph.
    func canRemoveEdge(_ edge: SceneGraphEdge) -> Bool {
        return true
    }

    /// Commits a connection represented by a given visual connection element
    /// to the graph.
    private func commitConnectionElement(_ element: SceneGraphConnectionElement) {
        guard let uiDelegate else { return }

        switch (element.startAnchor, element.endAnchor) {
        case (.output(let startView, let outputInfo), .input(let endView, let inputInfo)),
            (.input(let endView, let inputInfo), .output(let startView, let outputInfo)):
            guard let (start, output) = getNodeAndOutput(startView, index: outputInfo.index) else {
                break
            }
            guard let (end, input) = getNodeAndInput(endView, index: inputInfo.index) else {
                break
            }

            if let edge = connect(start: start, output: output, end: end, input: input) {
                uiDelegate.sceneGraphBuilderController(
                    self,
                    createViewForEdge: edge
                )
            }

        default:
            break
        }

        uiDelegate.sceneGraphBuilderController(
            self,
            removeConnectionElement: element
        )
    }

    /// Returns `true` if a combination of start/end nodes can be connected by
    /// a given pair of their output/inputs.
    private func canConnect(
        start: SceneGraphNode,
        output: SceneGraphNodeOutput,
        end: SceneGraphNode,
        input: SceneGraphNodeInput
    ) -> Bool {

        // Data types must be compatible
        guard SceneNodeDataType.areAssignable(source: output.type, target: input.type) else {
            return false
        }

        // Avoid loops
        guard !sceneGraph.hasPath(from: end, to: start) else {
            return false
        }

        // Avoid repeated connections
        guard !sceneGraph.hasEdge(from: start, output, to: end, input) else {
            return false
        }

        return true
    }

    /// From a given starting node and output, suggests an input on an end node
    /// that input could be connected to.
    ///
    /// Result is `nil` if nodes cannot be connected, or if the number of
    /// compatible inputs is not exactly 1.
    private func suggestInput(
        start: SceneGraphNode,
        output: SceneGraphNodeOutput,
        end: SceneGraphNode
    ) -> SceneGraphNodeInput? {

        var found: [SceneGraphNodeInput] = []
        for input in end.inputs {
            if canConnect(start: start, output: output, end: end, input: input) {
                found.append(input)
            }
        }

        return found.count == 1 ? found.first : nil
    }

    /// From a given starting node and input, suggests an output on an end node
    /// that output could be connected to.
    ///
    /// Result is `nil` if nodes cannot be connected, or if the number of
    /// compatible outputs is not exactly 1.
    private func suggestOutput(
        start: SceneGraphNode,
        end: SceneGraphNode,
        input: SceneGraphNodeInput
    ) -> SceneGraphNodeOutput? {

        var found: [SceneGraphNodeOutput] = []
        for output in start.outputs {
            if canConnect(start: start, output: output, end: end, input: input) {
                found.append(output)
            }
        }

        return found.count == 1 ? found.first : nil
    }

    /// Attempts to connect two nodes at a specified output/input combination.
    ///
    /// Returns a graph edge for the connection that was made, if it was
    /// successful, or `nil` if it could not be done.
    @discardableResult
    private func connect(
        start: SceneGraphNode,
        output: SceneGraphNodeOutput,
        end: SceneGraphNode,
        input: SceneGraphNodeInput
    ) -> SceneGraphEdge? {

        guard canConnect(start: start, output: output, end: end, input: input) else {
            return nil
        }

        return sceneGraph.addEdge(from: start, output, to: end, input)
    }
}
