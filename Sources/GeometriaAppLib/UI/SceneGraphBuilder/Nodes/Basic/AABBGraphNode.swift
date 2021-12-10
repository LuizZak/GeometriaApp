class AABBGraphNode: GeometryGraphNode {
    override var displayInformation: DisplayInformation {
        .init(
            icon: IconLibrary.aabbIcon,
            title: "AABB"
        )
    }

    override var outputs: [SceneGraphNodeOutput] {
        [
            Output<AABBElement>(name: "AABB", index: 0, type: .geometry)
        ]
    }

    var aabb: RAABB3D
    var material: MaterialId

    init(aabb: RAABB3D, material: MaterialId) {
        self.aabb = aabb
        self.material = material

        super.init()
    }

    override func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        AnyElement(AABBElement(geometry: aabb, material: material))
    }
}

extension AABBElement: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        .geometry
    }
}
