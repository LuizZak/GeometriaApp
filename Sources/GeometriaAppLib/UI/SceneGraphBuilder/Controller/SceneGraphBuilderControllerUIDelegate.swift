import ImagineUI

/// Encapsulates a scene graph element from a scene graph that can be manipulated
/// by the mouse by a user.
enum SceneGraphMouseElementKind {
    case node(node: SceneGraphNode, SceneGraphNodeView)
    case input(View, SceneGraphNodeInput, node: SceneGraphNode, SceneGraphNodeView)
    case output(View, SceneGraphNodeOutput, node: SceneGraphNode, SceneGraphNodeView)
}

/// Delegate for UI interactions of a scene graph builder controller.
protocol SceneGraphBuilderControllerUIDelegate: AnyObject {
    // MARK: - Querying 

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        nodeUnder point: UIPoint
    ) -> SceneGraphNodeView?

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        viewForGraphNode node: SceneGraphNode
    ) -> SceneGraphNodeView?

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        elementUnder point: UIPoint
    ) -> SceneGraphMouseElementKind?

    func sceneGraphBuilderControllerNodesContainer(
        _ controller: SceneGraphBuilderController
    ) -> SceneGraphBuilderNodeContainer

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        convertPoint point: UIPoint,
        from reference: SpatialReferenceType?
    ) -> UIPoint

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        convertPoint point: UIPoint,
        to reference: SpatialReferenceType?
    ) -> UIPoint

    // MARK: - Manipulating

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        createViewForNode node: SceneGraphNode
    ) -> SceneGraphNodeView

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        translateViewportToLocation location: UIPoint
    )

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        zoomViewportBy zoom: Double
    )

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        moveView view: View,
        toLocation location: UIPoint
    )

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        bringNodeViewToFront nodeView: SceneGraphNodeView
    )

    /// Requests that a new connection element be created and added to the
    /// interface.
    func sceneGraphBuilderControllerCreateConnectionElement(
        _ controller: SceneGraphBuilderController
    ) -> SceneGraphConnectionElement

    /// Updates the starting anchor for a connection element.
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        updateStartAnchorFor element: SceneGraphConnectionElement,
        _ anchor: SceneGraphConnectionElement.AnchorElement?
    )

    /// Updates the ending anchor for a connection element.
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        updateEndAnchorFor element: SceneGraphConnectionElement,
        _ anchor: SceneGraphConnectionElement.AnchorElement?
    )

    /// Requests that a connection element be removed from the interface.
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        removeConnectionElement element: SceneGraphConnectionElement
    )

    // MARK: - UI components

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        openContextMenuFor view: SceneGraphNodeView,
        location: UIPoint
    )
}
