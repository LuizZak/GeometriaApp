class CameraNode: SceneGraphNode {
    @SceneGraphNodeInputsBuilder
    override var inputs: [SceneGraphNodeInput] {
        viewportSize
        viewportCenter
    }

    @SceneGraphNodeOutputsBuilder
    override var outputs: [SceneGraphNodeOutput] {
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

    override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        Camera(
            viewportSize: try delegate.getTypedValue(for: self, input: viewportSize),
            viewportCenter: try delegate.getTypedValue(for: self, input: viewportCenter)
        )
    }
}

extension Camera: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        .camera
    }
}
