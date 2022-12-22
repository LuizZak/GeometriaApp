import ImagineUI

/// Controls UI interactions with a scene graph builder interface.
class SceneGraphBuilderController {
    private var _mouseState: MouseState = .none

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
    
    func onMouseDown(_ event: MouseEventArgs) {
        if event.buttons == .left {
            if let element = elementUnder(point: event.location) {
                switch element {
                case .node(_, let node):
                    beginNodeDrag(node, mouseLocation: event.location)
                
                case .input(let view, let input, let node, _):
                    beginInputDrag(view, input: input, node: node)
                
                case .output(let view, let output, let node, _):
                    beginOutputDrag(view, output: output, node: node)
                
                case .connection:
                    break
                }
            } else {
                withNodeContainer { container in
                    _mouseState = .draggingViewport(initialOffset: event.location - container.translation)
                }
            }
        }
    }

    func onMouseMove(_ event: MouseEventArgs) {
        updateDragState(event.location)
    }

    func onMouseUp(_ event: MouseEventArgs) {
        endDragState(event.location)
    }

    func onMouseClick(_ event: MouseEventArgs) {
        rightButton:
        if event.buttons == .right {
            guard let uiElement = elementUnder(point: event.location) else {
                break rightButton
            }

            switch uiElement {
            case .node(_, let view):
                openContextMenu(
                    for: view,
                    location: convert(point: event.location, to: nil)
                )
            default:
                break
            }
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
                uiDelegate?.sceneGraphBuilderController(self, zoomViewportBy: zoom)
            }
        }
    }

    // MARK: - Internals

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
        _ view: View,
        input: SceneGraphNodeInput,
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
            .input(nodeView, index: input.index)
        )

        let operation = InputDragOperation(
            view: view,
            input: input,
            node: node,
            connection: connection
        )

        _mouseState = .draggingInput(operation)
    }

    private func beginOutputDrag(
        _ view: View,
        output: SceneGraphNodeOutput,
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
            .output(nodeView, index: output.index)
        )

        let operation = OutputDragOperation(
            view: view,
            output: output,
            node: node,
            connection: connection
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

            uiDelegate.sceneGraphBuilderController(
                self,
                updateEndAnchorFor: operation.connection,
                endAnchor
            )
            
        case .draggingOutput(let operation):
            let endAnchor = operation.suggestedDragEndAnchor(
                mouseLocation: location,
                in: self
            )
            
            uiDelegate.sceneGraphBuilderController(
                self,
                updateEndAnchorFor: operation.connection,
                endAnchor
            )
        }
    }

    private func endDragState(_ location: UIPoint) {
        defer { _mouseState = .none }

        guard let uiDelegate else { return }
        
        switch _mouseState {
        case .draggingInput(let operation):
            let endAnchor = operation.suggestedDragEndAnchor(
                mouseLocation: location,
                in: self
            )
            uiDelegate.sceneGraphBuilderController(
                self,
                updateEndAnchorFor: operation.connection,
                endAnchor
            )

            commitConnectionElement(operation.connection)
        
        case .draggingOutput(let operation):
            let endAnchor = operation.suggestedDragEndAnchor(
                mouseLocation: location,
                in: self
            )
            uiDelegate.sceneGraphBuilderController(
                self,
                updateEndAnchorFor: operation.connection,
                endAnchor
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

    private func openContextMenu(for view: SceneGraphNodeView, location: UIPoint) {
        guard let uiDelegate else { return }

        let items = ContextMenuView.createItems {
            ContextMenuItem(title: "Delete") {
                //self._removeNodeView(view)
            }
        }
        
        uiDelegate.sceneGraphBuilderController(
            self,
            openContextMenu: items,
            location: location
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

        func suggestedDragEndAnchor(
            mouseLocation: UIPoint,
            in controller: SceneGraphBuilderController
        ) -> SceneGraphConnectionElement.AnchorElement {

            let elements = controller.allElementsUnder(point: mouseLocation)

            outerLoop:
            for element in elements {
                switch element {
                case .node, .input:
                    break outerLoop
                
                case .output(_, let output, let graphNode, let nodeView):
                    if controller.canConnect(
                        start: graphNode,
                        output: output,
                        end: node,
                        input: input
                    ) {
                        return .output(nodeView, index: output.index)
                    }
                
                case .connection:
                    continue
                }
            }

            let global = controller.convert(point: mouseLocation, to: nil)
            return .globalLocation(global)
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

        func suggestedDragEndAnchor(
            mouseLocation: UIPoint,
            in controller: SceneGraphBuilderController
        ) -> SceneGraphConnectionElement.AnchorElement {

            let elements = controller.allElementsUnder(point: mouseLocation)

            outerLoop:
            for element in elements {
                switch element {
                case .node(let graphNode, let nodeView),
                    .output(_, _, let graphNode, let nodeView):

                    if let input = controller.suggestInput(
                        start: node,
                        output: output,
                        end: graphNode
                    ) {
                        return .input(nodeView, index: input.index)
                    }

                    break outerLoop
                
                case .input(_, let input, let graphNode, let nodeView):
                    if controller.canConnect(
                        start: node,
                        output: output,
                        end: graphNode,
                        input: input
                    ) {
                        return .input(nodeView, index: input.index)
                    }

                    break outerLoop
                
                case .connection:
                    continue
                }
            }

            let global = controller.convert(point: mouseLocation, to: nil)
            return .globalLocation(global)
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
}

// MARK: - Node connections

extension SceneGraphBuilderController {
    /// Commits a connection represented by a given visual connection element
    /// to the graph.
    private func commitConnectionElement(_ element: SceneGraphConnectionElement) {
        guard let uiDelegate else { return }

        switch (element.startAnchor, element.endAnchor) {
        case (.output(let startView, let outputIndex), .input(let endView, let inputIndex)):
            guard let (start, output) = getNodeAndOutput(startView, index: outputIndex) else {
                break
            }
            guard let (end, input) = getNodeAndInput(endView, index: inputIndex) else {
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
