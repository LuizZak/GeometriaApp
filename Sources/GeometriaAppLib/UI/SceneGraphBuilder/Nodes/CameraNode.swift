class CameraNode: SceneGraphNode {
    @SceneGraphNodeOutputsBuilder
    override var outputs: [SceneGraphNodeOutput] {
        output
    }

    let output = Output<Camera>(
        name: "Camera",
        index: 0,
        type: .camera
    )

    override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        Camera(viewportSize: .zero)
    }
}

extension Camera: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        .camera
    }
}
