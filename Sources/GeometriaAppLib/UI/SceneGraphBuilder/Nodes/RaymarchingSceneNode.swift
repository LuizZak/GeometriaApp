import SwiftBlend2D

class RaymarchingSceneNode: GeometryGraphNode {
    override var displayInformation: DisplayInformation {
        .init(
            title: "Raymarching Scene"
        )
    }

    @SceneGraphNodeInputsBuilder
    override var inputs: [SceneGraphNodeInput] {
        rootNode
        skyColor
        sunDirection
        materialMap
    }

    @SceneGraphNodeOutputsBuilder
    override var outputs: [SceneGraphNodeOutput] {
        output
    }

    let rootNode = Input<AnyRaymarchingElement>(
        name: "Root element",
        index: 0
    )
    let skyColor = Input<BLRgba32>(
        name: "Sky color",
        index: 1
    )
    let sunDirection = Input<RVector3D>(
        name: "Sun direction",
        index: 2
    )
    let materialMap = Input<MaterialMap>(
        name: "Materials",
        index: 3
    )

    let output = Output<AnyRaymarchingScene>(
        name: "Scene",
        index: 0
    )

    override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        return AnyRaymarchingScene(
            root: try delegate.getTypedValue(for: self, input: rootNode),
            skyColor: try delegate.getTypedValue(for: self, input: skyColor),
            sunDirection: try delegate.getTypedValue(for: self, input: sunDirection),
            materialIdMap: try delegate.getTypedValue(for: self, input: materialMap)
        )
    }
}

extension RaymarchingScene: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        .raymarchingScene
    }
}

extension AnyRaymarchingScene: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        .raymarchingScene
    }
}

extension MaterialMap: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        .materialMap
    }
}
