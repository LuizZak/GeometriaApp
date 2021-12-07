class AABBGraphNode: GeometryGraphNode {
    override var displayInformation: DisplayInformation {
        .init(
            title: "AABB"
        )
    }

    override var outputs: [Output] {
        [
            .init(name: "AABB", type: .geometry)
        ]
    }

    var aabb: RAABB3D
    var material: MaterialId

    init(aabb: RAABB3D, material: MaterialId) {
        self.aabb = aabb
        self.material = material

        super.init()
    }

    override func makeElement() throws -> AnyElement {
        AnyElement(AABBElement(geometry: aabb, material: material))
    }
}
