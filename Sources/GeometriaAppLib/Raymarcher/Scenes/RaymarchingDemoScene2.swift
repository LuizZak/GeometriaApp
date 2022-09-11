import SwiftBlend2D

enum RaymarchingDemoScene2 {
    static func makeScene() -> some RaymarchingSceneType {
        let materials: MaterialMap = makeMaterialMap(MaterialMapEnum.self)

        return RaymarchingElementBuilder.makeScene(skyColor: .cornflowerBlue, materials: materials) {
            scene()
        }
    }
}

@RaymarchingElementBuilder
private func scene() -> some RaymarchingElement {
    makeFloorPlane()

    makeGreekBuilding(withBaseCenteredAt: .init(x: 0, y: 300, z: 0))
}

private func makeGreekBuilding(withBaseCenteredAt point: RVector3D) -> some RaymarchingElement & BoundedElement {
    let building = group {
        let pillars = makePillar(
            at: .init(x: 0, y: 0, z: 0),
            height: 80,
            radius: 7
        )
        .repeatTranslated(count: 10, translation: .unitX * 30).makeBoundingBox()
        .repeatTranslated(count: 2, translation: .unitY * 150).makeBoundingBox()

        let pillarBounds = pillars.makeBounds()

        let baseSize = pillarBounds.size[.x, .y] + .init(x: 5, y: 5)

        makeBase(
            center: .init(pillarBounds.center[.x, .y]),
            size: baseSize
        )

        makeTop(
            center: .init(pillarBounds.center[.x, .y], z: pillarBounds.maximum.z),
            size: baseSize
        )
        
        pillars
    }
    
    return building.centered(
        at: RVector3D(
            point[.x, .y], z: point.z + building.makeBounds().size.z / 2
        )
    ).makeBoundingBox()
}

@RaymarchingElementBuilder
private func makeBase(center: RVector3D, size: RVector2D) -> some RaymarchingElement & BoundedElement {
    let sizeIncrease = RVector3D(x: 5, y: 5, z: 0)
    let translation = RVector3D(x: 0, y: 0, z: -5)

    boundingBox {
        makeAABB(center: center + translation * 0, size: .init(size, z: 5) + sizeIncrease * 0)
        makeAABB(center: center + translation * 1, size: .init(size, z: 5) + sizeIncrease * 1)
        makeAABB(center: center + translation * 2, size: .init(size, z: 5) + sizeIncrease * 2)
        makeAABB(center: center + translation * 3, size: .init(size, z: 5) + sizeIncrease * 3)
        makeAABB(center: center + translation * 4, size: .init(size, z: 5) + sizeIncrease * 4)
    }
}

@RaymarchingElementBuilder
private func makeTop(center: RVector3D, size: RVector2D) -> some RaymarchingElement & BoundedElement {
    let sizeIncrease = RVector3D(x: 5, y: 5, z: 0)
    let translation = RVector3D(x: 0, y: 0, z: 5)

    boundingBox {
        makeAABB(center: center + translation * 0, size: .init(size, z: 5) + sizeIncrease * 0)
        makeAABB(center: center + translation * 1, size: .init(size, z: 5) + sizeIncrease * 1)
        makeAABB(center: center + translation * 2, size: .init(size, z: 5) + sizeIncrease * 2)
    }
}

@RaymarchingElementBuilder
private func makePillar(at point: RVector3D, height: Double, radius: Double) -> some RaymarchingElement & BoundedElement {
    let start = point
    let end = point + .unitZ * height

    boundingBox {
        cylinder(start: start, end: end, radius: radius, color: .white)
        cylinder(start: start, end: start + .unitZ * 5, radius: radius + 1, color: .white)
        cylinder(start: end, end: end - .unitZ * 5, radius: radius + 1, color: .white)
    }
}

private func cylinder(start: RVector3D, end: RVector3D, radius: Double, color: BLRgba32 = .gray) -> CylinderRaymarchingElement {
    CylinderRaymarchingElement(
        geometry: .init(start: start, end: end, radius: radius),
        material: MaterialMapEnum.monument.rawValue
    )
}

private func makeAABB(center: RVector3D, size: RVector3D) -> AABBRaymarchingElement {
    AABBRaymarchingElement(
        geometry: .init(minimum: center - size / 2, maximum: center + size / 2),
        material: MaterialMapEnum.monument.rawValue
    )
}

private func makeFloorPlane() -> PlaneRaymarchingElement {
    PlaneRaymarchingElement(
        geometry: .init(point: .zero, normal: .unitZ),
        material: MaterialMapEnum.floor.rawValue
    )
}

private enum MaterialMapEnum: Int, CaseIterable, MaterialMapEnumType {
    case floor = 1
    case monument = 2

    func makeMaterial() -> Material {
        switch self {
        case .floor:
            return .checkerboard(
                size: 50.0, 
                color1: .white, 
                color2: .black
            )
        
        case .monument:
            return .solid(.white)
        }
    }
}
