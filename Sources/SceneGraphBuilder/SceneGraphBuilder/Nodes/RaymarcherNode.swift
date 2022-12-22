import GeometriaAppLib

public class RaymarcherNode: SceneGraphNode, InitializableSceneGraphNode {
    public override var displayInformation: DisplayInformation {
        .init(
            title: "Raymarching Renderer"
        )
    }

    @SceneGraphNodeInputsBuilder
    public override var inputs: [SceneGraphNodeInput] {
        scene
        camera
    }

    @SceneGraphNodeOutputsBuilder
    public override var outputs: [SceneGraphNodeOutput] {
        output
    }

    let scene = Input<AnyRaymarchingScene>(
        name: "Scene",
        index: 0
    )
    let camera = Input<Camera>(
        name: "Root element",
        index: 1
    )

    let output = Output<Raymarcher<AnyRaymarchingScene>>(
        name: "Raymarcher",
        index: 0
    )

    public override required init() {
        super.init()
    }

    public override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        return Raymarcher<AnyRaymarchingScene>(
            scene: try delegate.getTypedValue(for: self, input: scene),
            camera: try delegate.getTypedValue(for: self, input: camera)
        )
    }
}

extension Raymarcher: SceneNodeDataTypeRepresentable {
    public static var staticDataType: SceneNodeDataType {
        .raymarchingScene
    }
}
