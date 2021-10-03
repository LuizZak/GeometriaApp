enum RaymarchingDemoScene2 {
    static func makeScene() -> some RaymarchingSceneType {
        RaymarchingElementBuilder.makeScene(skyColor: .cornflowerBlue) {
            scene()
        }
    }
}

@RaymarchingElementBuilder
private func scene() -> some RaymarchingElement {
    makeFloorPlane()

    boundingBox {
        repeatTranslate(count: 10, translation: .unitX * 30) {
            makePillar(at: .init(x: -120, y: 200, z: 0),
                    height: 50,
                    radius: 7)
        }
    }
}

@RaymarchingElementBuilder
private func makePillar(at point: RVector3D, height: Double, radius: Double) -> some BoundedRaymarchingElement {
    let start = point
    let end = point + .unitZ * height

    boundingBox {
        cylinder(start: start, end: end, radius: radius)
        cylinder(start: start, end: start + .unitZ * 5, radius: radius + 1)
        cylinder(start: end, end: end - .unitZ * 5, radius: radius + 1)
    }
}

@RaymarchingElementBuilder
private func makeFloorPlane() -> some RaymarchingElement {
    (
        RPlane3D(point: .zero, normal: .unitZ),

        RaymarcherMaterial.checkerboard(size: 50.0, color1: .white, color2: .black)
    )
}

@RaymarchingElementBuilder
private func cylinder(start: RVector3D, end: RVector3D, radius: Double) -> some BoundedRaymarchingElement {
    (
        RCylinder3D(start: start, end: end, radius: radius)
    )
}
