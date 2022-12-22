import GeometriaAppLib

public class AABBGraphNode: GeometryGraphNode {
    public override var displayInformation: DisplayInformation {
        .init(
            title: "AABB",
            icon: IconLibrary.aabbIcon
        )
    }

    public override var outputs: [SceneGraphNodeOutput] {
        [
            Output<AABBElement>(name: "AABB", index: 0, type: .geometry)
        ]
    }

    public var aabb: RAABB3D
    public var material: MaterialId

    public init(aabb: RAABB3D, material: MaterialId) {
        self.aabb = aabb
        self.material = material

        super.init()
    }

    public override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        AnyElement(AABBElement(geometry: aabb, material: material))
    }
}

extension AABBElement: SceneNodeDataTypeRepresentable {
    public static var staticDataType: SceneNodeDataType {
        .geometry
    }
}
