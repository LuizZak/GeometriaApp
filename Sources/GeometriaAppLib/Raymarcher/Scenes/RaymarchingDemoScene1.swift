enum RaymarchingDemoScene1 {
    static func makeScene() -> some RaymarchingSceneType {
        RaymarchingElementBuilder.makeScene(skyColor: .cornflowerBlue) {
            scene()
        }
    }
}

@RaymarchingElementBuilder
private func scene() -> some RaymarchingElement {
    boundingBox {
        group {
            makeBackAABB()
            makeTopAABB()
            makeShinySphere()

            // TODO: Add ellipse support to raymarching
            //makeEllipse()

            makeDisk()
                .repeatTranslated(count: 5, translation: .unitX * 30)
                .makeBoundingBox()
        }

        group {
            makeCylinder()
            makeBumpySphere()
        }
    }
    
    makeFloorPlane()
}

@_transparent
private func makeBackAABB() -> AABBRaymarchingElement {
    .init(
        geometry: .init(
            minimum: .init(x: -50, y: 200, z: 10),
            maximum: .init(x: 0, y: 210, z: 50)
        ),
        material: .diffuse(.init(color: .indianRed))
    )
}

@_transparent
private func makeTopAABB() -> AABBRaymarchingElement {
    .init(
        geometry: .init(
            minimum: .init(x: -70, y: 120, z: 60),
            maximum: .init(x: 10, y: 140, z: 112)
        ),
        material: .default
    )
}

@_transparent
private func makeShinySphere() -> SphereRaymarchingElement {
    .init(
        geometry: .init(
            center: .init(x: 0, y: 150, z: 45), 
            radius: 30
        ),
        material: .diffuse(
            .init(color: .gray,
                  reflectivity: 0.6,
                  transparency: 1.0,
                  refractiveIndex: 1.3)
        )
    )
}

@_transparent
private func makeCylinder() -> CylinderRaymarchingElement {
    .init(
        geometry: .init(
            start: .init(x: 60, y: 150, z: 0),
            end: .init(x: 60, y: 150, z: 100),
            radius: 20
        ),
        material: .diffuse(
            .init(color: .init(r: 128, g: 128, b: 128, a: 255),
                  bumpNoiseFrequency: 1.0,
                  bumpMagnitude: 0.0,
                  reflectivity: 0.0,
                  transparency: 1.0,
                  refractiveIndex: 1.3)
        )
    )
}

@_transparent
private func makeBumpySphere() -> SphereRaymarchingElement {
    // TODO: Add support for bumpy materials
    .init(
        geometry: .init(
            center: .init(x: 70, y: 150, z: 45), 
            radius: 30
        ),
        material: .diffuse(
            .init(bumpNoiseFrequency: 1.0,
                  bumpMagnitude: 1.0 / 40.0,
                  reflectivity: 0.4)
        )
    )
}

/*
@_transparent
private func makeEllipse() -> EllipseRaymarchingElement {
    .init(
        geometry: .init(
            center: .init(x: -50, y: 90, z: 20),
            radius: .init(x: 20, y: 15, z: 10)
        ),
        material: .diffuse(
            .init(reflectivity: 0.5)
        )
    )
}
*/

@_transparent
private func makeDisk() -> DiskRaymarchingElement {
    .init(
        geometry: .init(
            center: .init(x: -10, y: 110, z: 20),
            normal: .unitY,
            radius: 12
        ),
        material: .target(
            center: .init(x: -10, y: 110, z: 20),
            stripeFrequency: 5.0,
            color1: .red,
            color2: .white
        )
    )
}

@_transparent
private func makeFloorPlane() -> PlaneRaymarchingElement {
    .init(
        geometry: .init(
            point: .zero, 
            normal: .unitZ
        ),
        material: .checkerboard(
            size: 50.0, 
            color1: .white, 
            color2: .black
        )
    )
}
