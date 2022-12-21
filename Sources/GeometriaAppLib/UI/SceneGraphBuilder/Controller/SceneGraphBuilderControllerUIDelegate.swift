import ImagineUI

/// Encapsulates a UI element from a scene graph that can be manipulated by the
/// mouse by a user.
enum SceneGraphMouseElementKind {
    case nodeView(SceneGraphNodeView)
    case connectionView(View)
}

/// Delegate for UI interactions of a scene graph builder controller.
protocol SceneGraphBuilderControllerUIDelegate: AnyObject {
    // MARK: - Querying 

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        nodeUnder point: UIPoint
    ) -> SceneGraphNodeView?

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

    // MARK: - UI components

    func sceneGraphBuilderController(
        _ controller: SceneGraphBuilderController,
        openContextMenuFor view: SceneGraphNodeView,
        location: UIPoint
    )
}
