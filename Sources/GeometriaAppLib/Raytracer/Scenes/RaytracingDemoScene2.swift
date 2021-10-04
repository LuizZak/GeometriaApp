import SwiftBlend2D

enum RaytracingDemoScene2 {
    static func makeScene() -> some RaytracingSceneType {
        RaytracingElementBuilder.makeScene(skyColor: .cornflowerBlue) {
            scene()
        }
    }
}

@RaytracingElementBuilder
private func scene() -> some RaytracingElement {
    makeFloorPlane()

    makeGreekBuilding(withBaseCenteredAt: .init(x: 0, y: 300, z: 0))
}

private func makeGreekBuilding(withBaseCenteredAt point: RVector3D) -> some RaytracingElement & BoundedElement {
    let building = group {
        let pillars = makePillar(
            at: .init(x: 0, y: 0, z: 0),
            height: 80,
            radius: 7
        )
        .repeatTranslated(count: 10, translation: .unitX * 30).makeBoundingBox()
        .repeatTranslated(count: 2, translation: .unitY * 150).makeBoundingBox()

        let pillarBounds = pillars.makeBounds()

        let baseSize = pillarBounds.size.take.xy + .init(x: 5, y: 5)

        makeBase(
            center: .init(pillarBounds.center.take.xy),
            size: baseSize
        )

        makeTop(
            center: .init(pillarBounds.center.take.xy, z: pillarBounds.maximum.z),
            size: baseSize
        )
        
        pillars
    }

    return building.centered(at: .init(point.take.xy, z: point.z + building.makeBounds().size.z / 2)).makeBoundingBox()
}

@RaytracingElementBuilder
private func makeBase(center: RVector3D, size: RVector2D) -> some RaytracingElement & BoundedElement {
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

@RaytracingElementBuilder
private func makeTop(center: RVector3D, size: RVector2D) -> some RaytracingElement & BoundedElement {
    let sizeIncrease = RVector3D(x: 5, y: 5, z: 0)
    let translation = RVector3D(x: 0, y: 0, z: 5)

    boundingBox {
        makeAABB(center: center + translation * 0, size: .init(size, z: 5) + sizeIncrease * 0)
        makeAABB(center: center + translation * 1, size: .init(size, z: 5) + sizeIncrease * 1)
        makeAABB(center: center + translation * 2, size: .init(size, z: 5) + sizeIncrease * 2)
    }
}

@RaytracingElementBuilder
private func makePillar(at point: RVector3D, height: Double, radius: Double) -> some RaytracingElement & BoundedElement {
    let start = point
    let end = point + .unitZ * height

    boundingBox {
        cylinder(start: start, end: end, radius: radius, color: .white)
        cylinder(start: start, end: start + .unitZ * 5, radius: radius + 1, color: .white)
        cylinder(start: end, end: end - .unitZ * 5, radius: radius + 1, color: .white)
    }
}

private func cylinder(start: RVector3D, end: RVector3D, radius: Double, color: BLRgba32 = .gray) -> CylinderRaytracingElement {
    CylinderRaytracingElement(
        geometry: .init(start: start, end: end, radius: radius),
        material: .solid(color)
    )
}

private func makeAABB(center: RVector3D, size: RVector3D) -> AABBRaytracingElement {
    AABBRaytracingElement(
        geometry: .init(minimum: center - size / 2, maximum: center + size / 2),
        material: .solid(.white)
    )
}

private func makeFloorPlane() -> PlaneRaytracingElement {
    PlaneRaytracingElement(
        geometry: .init(point: .zero, normal: .unitZ),
        material: .checkerboard(size: 50.0, color1: .white, color2: .black)
    )
}
