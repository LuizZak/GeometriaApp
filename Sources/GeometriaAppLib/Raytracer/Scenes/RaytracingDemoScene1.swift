enum RaytracingDemoScene1 {
    static func makeScene() -> some RaytracingSceneType {
        let materials: MaterialMap = makeMaterialMap(MaterialMapEnum.self)
        
        return RaytracingElementBuilder.makeScene(skyColor: .cornflowerBlue, materials: materials) {
            scene()
        }
    }
}

@RaytracingElementBuilder
private func scene() -> some RaytracingElement {
    boundingBox {
        boundingBox {
            makeBackAABB()
            makeTopAABB()
            makeShinySphere()
            makeEllipse()

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
private func makeBackAABB() -> AABBRaytracingElement {
    .init(
        geometry: .init(
            minimum: .init(x: -50, y: 200, z: 10),
            maximum: .init(x: 0, y: 210, z: 50)
        ),
        material: MaterialMapEnum.backAABB.rawValue
    )
}

@_transparent
private func makeTopAABB() -> AABBRaytracingElement {
    .init(
        geometry: .init(
            minimum: .init(x: -70, y: 120, z: 60),
            maximum: .init(x: 10, y: 140, z: 112)
        ),
        material: MaterialMapEnum.default.rawValue
    )
}

@_transparent
private func makeShinySphere() -> SphereRaytracingElement {
    .init(
        geometry: .init(
            center: .init(x: 0, y: 150, z: 45), 
            radius: 30
        ),
        material: MaterialMapEnum.shiny.rawValue
    )
}

@_transparent
private func makeCylinder() -> CylinderRaytracingElement {
    .init(
        geometry: .init(
            start: .init(x: 60, y: 150, z: 0),
            end: .init(x: 60, y: 150, z: 100),
            radius: 20
        ),
        material: MaterialMapEnum.cylinder.rawValue
    )
}

@_transparent
private func makeBumpySphere() -> SphereRaytracingElement {
    // TODO: Add support for bumpy materials
    .init(
        geometry: .init(
            center: .init(x: 70, y: 150, z: 45), 
            radius: 30
        ),
        material: MaterialMapEnum.bumpy.rawValue
    )
}

@_transparent
private func makeEllipse() -> EllipseRaytracingElement {
    .init(
        geometry: .init(
            center: .init(x: -50, y: 90, z: 20),
            radius: .init(x: 20, y: 15, z: 10)
        ),
        material: MaterialMapEnum.reflective.rawValue
    )
}

@_transparent
private func makeDisk() -> DiskRaytracingElement {
    .init(
        geometry: .init(
            center: .init(x: -10, y: 110, z: 20),
            normal: .unitY,
            radius: 12
        ),
        material: MaterialMapEnum.disk.rawValue
    )
}

@_transparent
private func makeFloorPlane() -> PlaneRaytracingElement {
    .init(
        geometry: .init(
            point: .zero, 
            normal: .unitZ
        ),
        material: MaterialMapEnum.floor.rawValue
    )
}

private enum MaterialMapEnum: Int, CaseIterable, MaterialMapEnumType {
    case `default` = 0
    case floor = 1
    case disk = 2
    case backAABB = 3
    case bumpy = 4
    case shiny = 5
    case cylinder = 6
    case reflective = 7

    func makeMaterial() -> Material {
        switch self {
        case .default:
            return .default

        case .floor:
            return .checkerboard(
                size: 50.0, 
                color1: .white, 
                color2: .black
            )
        
        case .disk:
            return .target(
                center: .init(x: -10, y: 110, z: 20),
                stripeFrequency: 5.0,
                color1: .red,
                color2: .white
            )
        
        case .backAABB:
            return .diffuse(
                .init(color: .indianRed)
            )
        
        case .bumpy:
            return .diffuse(
                .init(
                    bumpNoiseFrequency: 1.0,
                    bumpMagnitude: 1.0 / 40.0,
                    reflectivity: 0.4
                )
            )

        case .cylinder:
            return .diffuse(
                .init(
                    color: .init(r: 128, g: 128, b: 128, a: 255),
                    bumpNoiseFrequency: 1.0,
                    bumpMagnitude: 0.0,
                    reflectivity: 0.0,
                    transparency: 1.0,
                    refractiveIndex: 1.3
                )
            )

        case .shiny:
            return .diffuse(
                .init(
                    color: .gray,
                    reflectivity: 0.6,
                    transparency: 1.0,
                    refractiveIndex: 1.3
                )
            )

        case .reflective:
            return .diffuse(
                .init(reflectivity: 0.5)
            )
        }
    }
}
