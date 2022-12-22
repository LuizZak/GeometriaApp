import GeometriaAppLib

public class CameraNode: SceneGraphNode, InitializableSceneGraphNode {
    @SceneGraphNodeInputsBuilder
    public override var inputs: [SceneGraphNodeInput] {
        viewportSize
        viewportCenter
    }

    @SceneGraphNodeOutputsBuilder
    public override var outputs: [SceneGraphNodeOutput] {
        output
    }

    let output = Output<Camera>(
        name: "Camera",
        index: 0,
        type: .camera
    )

    let viewportSize = Input<ViewportSize>(
        name: "Viewport size",
        index: 0
    )
    let viewportCenter = Input<RVector3D>(
        name: "Viewport center",
        index: 1
    )

    public override required init() {
        super.init()
    }

    public override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        Camera(
            viewportSize: try delegate.getTypedValue(for: self, input: viewportSize),
            viewportCenter: try delegate.getTypedValue(for: self, input: viewportCenter)
        )
    }
}

extension Camera: SceneNodeDataTypeRepresentable {
    public static var staticDataType: SceneNodeDataType {
        .camera
    }
}
