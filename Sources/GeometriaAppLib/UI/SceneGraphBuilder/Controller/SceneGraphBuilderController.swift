import ImagineUI

/// Controls UI interactions with a scene graph builder interface.
class SceneGraphBuilderController {
    private var _mouseState: MouseState = .none

    weak var uiDelegate: SceneGraphBuilderControllerUIDelegate?
    
    func onMouseDown(_ event: MouseEventArgs) {
        if event.buttons == .left {
            if let node = nodeUnder(point: event.location) {
                node.bringToFrontOfSuperview()
                
                withNodeContainer { container in
                    _mouseState = .draggingNode(
                        ViewDragOperation(
                            view: node,
                            container: container,
                            offset: convert(point: event.location, to: node)
                        )
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
        switch _mouseState {
        case .none:
            break
        case .draggingViewport(let offset):
            withNodeContainer { container in
                container.translation = event.location - offset
            }
            
        case .draggingNode(let operation):
            let point = convert(point: event.location, to: operation.container)

            uiDelegate?.sceneGraphBuilderController(
                self,
                moveView: operation.view,
                toLocation: point - operation.offset
            )
        }
    }

    func onMouseUp(_ event: MouseEventArgs) {
        _mouseState = .none
    }

    func onMouseClick(_ event: MouseEventArgs) {
        if event.buttons == .right, let node = nodeUnder(point: event.location) {
            openContextMenu(for: node, location: convert(point: event.location, to: nil))
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

    private func nodeUnder(point: UIPoint) -> SceneGraphNodeView? {
        guard let uiDelegate else { return nil }

        return uiDelegate.sceneGraphBuilderController(self, nodeUnder: point)
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

    private func openContextMenu(for view: SceneGraphNodeView, location: UIPoint) {
        guard let uiDelegate else { return }

        uiDelegate.sceneGraphBuilderController(
            self,
            openContextMenuFor: view,
            location: location
        )
    }

    // MARK: - Types

    private enum MouseState {
        case none
        case draggingViewport(initialOffset: UIVector)
        case draggingNode(ViewDragOperation)
        // case draggingInput()
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
}
