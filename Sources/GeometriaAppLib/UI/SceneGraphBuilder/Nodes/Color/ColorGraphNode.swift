import SwiftBlend2D

class ColorGraphNode: SceneGraphNode {
    override var displayInformation: DisplayInformation {
        .init(
            title: "Color"
        )
    }

    override var outputs: [SceneGraphNodeOutput] {
        [
            Output<BLRgba32>(name: "Color", index: 0, type: .color),
        ]
    }

    override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        BLRgba32.white
    }
}

extension BLRgba32: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        .color
    }

    var dynamicDataType: SceneNodeDataType {
        .color
    }
}
