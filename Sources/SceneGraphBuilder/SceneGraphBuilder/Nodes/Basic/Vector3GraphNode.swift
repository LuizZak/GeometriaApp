import Geometria
import GeometriaAppLib

public class Vector3GraphNode: SceneGraphNode {
    public override var displayInformation: DisplayInformation {
        .init(
            title: "Vector3",
            icon: IconLibrary.vector3Icon
        )
    }

    public override var outputs: [SceneGraphNodeOutput] {
        [
            Output<RVector3D>(name: "Vector3", index: 0, type: .vector3)
        ]
    }

    public var vector: RVector3D

    public init(vector: RVector3D) {
        self.vector = vector

        super.init()
    }

    public override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        vector
    }
}

extension Vector3GraphNode: SceneNodeDataTypeRepresentable {
    public static var staticDataType: SceneNodeDataType {
        .vector3
    }
}
