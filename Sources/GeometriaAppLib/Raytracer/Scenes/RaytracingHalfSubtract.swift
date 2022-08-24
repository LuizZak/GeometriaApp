enum RaytracingHalfSubtract {
    @inlinable
    static func makeScene() -> some RaytracingSceneType {
        let materials: MaterialMap = makeMaterialMap(MaterialMapEnum.self)
        
        return RaytracingElementBuilder.makeScene(skyColor: .cornflowerBlue, materials: materials) {
            scene()
        }
    }
}

@RaytracingElementBuilder
private func scene() -> some RaytracingElement {
    makeFloorPlane()
    
    translated(x: 0, y: -80, z: 30) {
        boundingBox {
            let cubeCenter = RVector3D(x: 0, y: 100, z: 40)

            /*
            makeCylinder(
                start: cubeCenter,
                direction: RVector3D.unitY,
                length: 60,
                radius: 10
            )
            // */

            //*
            subtraction {
                makeCube(
                    center: cubeCenter,
                    sideLength: 30
                )

                makeCylinder(
                    start: cubeCenter,
                    direction: RVector3D.unitZ,
                    length: 60,
                    radius: 10
                )
            }
            // */
        }
    }
}

@_transparent
private func makeCube(center: RVector3D, sideLength: Double) -> CubeElement {
    let location = center - sideLength / 2

    return .init(
        geometry: .init(
            location: location,
            sideLength: sideLength
        ),
        material: MaterialMapEnum.semiTransparent.rawValue
    )
}

@_transparent
private func makeCylinder(center: RVector3D, direction: RVector3D, length: Double, radius: Double) -> CylinderElement {
    let start = center - direction * length / 2
    let end = center + direction * length / 2

    return .init(
        geometry: .init(
            start: start,
            end: end,
            radius: radius
        ),
        material: MaterialMapEnum.semiTransparent.rawValue
    )
}

@_transparent
private func makeCylinder(start: RVector3D, direction: RVector3D, length: Double, radius: Double) -> CylinderElement {
    let end = start + direction * length

    return .init(
        geometry: .init(
            start: start,
            end: end,
            radius: radius
        ),
        material: MaterialMapEnum.semiTransparent.rawValue
    )
}

private func makeFloorPlane() -> PlaneRaytracingElement {
    PlaneRaytracingElement(
        geometry: .init(point: .zero, normal: .unitZ),
        material: MaterialMapEnum.floor.rawValue
    )
}

private enum MaterialMapEnum: Int, CaseIterable, MaterialMapEnumType {
    case `default` = 0
    case floor = 1
    case semiTransparent = 2

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
            
        case .semiTransparent:
            return .diffuse(
                .init(
                    color: .init(r: 128, g: 128, b: 128, a: 255),
                    //bumpNoiseFrequency: 1.0,
                    //bumpMagnitude: 0.0,
                    //reflectivity: 0.2,
                    transparency: 0.8
                    //refractiveIndex: 1.3
                )
            )
        }
    }
}
