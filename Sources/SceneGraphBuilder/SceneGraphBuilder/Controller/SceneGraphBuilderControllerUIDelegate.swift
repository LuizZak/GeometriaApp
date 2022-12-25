import ImagineUI
import GeometriaAppLib

/// Encapsulates a scene graph element from a scene graph that can be manipulated
/// by the mouse by a user.
enum SceneGraphMouseElementKind {
    case node(node: SceneGraphNode, SceneGraphNodeView)
    case input(SceneGraphNodeView.InputViewInfo, node: SceneGraphNode, SceneGraphNodeView)
    case output(SceneGraphNodeView.OutputViewInfo, node: SceneGraphNode, SceneGraphNodeView)
    case connection(SceneGraphConnectionElement, edge: SceneGraphEdge)
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

    /// Returns the top-most UI element that is mouse-interactive at a given point.
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        elementUnder point: UIPoint
    ) -> SceneGraphMouseElementKind?

    /// Returns all UI elements that are mouse-interactive at a given point,
    /// ordered from top-most to bottom-most, in terms of rendering order.
    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        allElementsUnder point: UIPoint
    ) -> [SceneGraphMouseElementKind]

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
        createViewForEdge edge: SceneGraphEdge
    )

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

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        bringEdgeToFront element: SceneGraphConnectionElement
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
        openContextMenu items: [ContextMenuItemEntry],
        location: UIPoint
    )

    func sceneGraphBuilderBeginCustomTooltipLifetime(
        _ controller: SceneGraphBuilderController
    ) -> CustomTooltipHandlerType?
}
