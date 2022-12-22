import SwiftBlend2D

public class ColorGraphNode: SceneGraphNode {
    public override var displayInformation: DisplayInformation {
        .init(
            title: "Color"
        )
    }

    public override var outputs: [SceneGraphNodeOutput] {
        [
            Output<BLRgba32>(name: "Color", index: 0, type: .color),
        ]
    }

    public override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        BLRgba32.white
    }
}

extension BLRgba32: SceneNodeDataTypeRepresentable {
    public static var staticDataType: SceneNodeDataType {
        .color
    }

    public var dynamicDataType: SceneNodeDataType {
        .color
    }
}
