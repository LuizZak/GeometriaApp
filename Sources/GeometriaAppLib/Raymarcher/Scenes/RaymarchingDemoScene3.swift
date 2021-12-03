enum RaymarchingDemoScene3 {
    @inlinable
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
    
    subtraction {
        intersection {
            makeCube(
                center: .init(x: 0, y: 100, z: 40),
                sideLength: 30
            )
            makeSphere(
                center: .init(x: 0, y: 100, z: 40),
                radius: 20
            )
        }
        makeCylinder(
            center: .init(x: 0, y: 100, z: 40),
            direction: .unitZ,
            length: 40,
            radius: 10
        )
        makeCylinder(
            center: .init(x: 0, y: 100, z: 40),
            direction: .unitY,
            length: 40,
            radius: 10
        )
        makeCylinder(
            center: .init(x: 0, y: 100, z: 40),
            direction: .unitX,
            length: 40,
            radius: 10
        )
    }
    .makeBoundingBox()
}

@_transparent
private func makeCube(center: RVector3D, sideLength: Double) -> CubeElement {
    let location = center - sideLength / 2

    return .init(
        geometry: .init(
            location: location,
            sideLength: sideLength
        ),
        material: MaterialMapEnum.default.rawValue
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
        material: MaterialMapEnum.default.rawValue
    )
}

@_transparent
private func makeSphere(center: RVector3D, radius: Double) -> SphereRaytracingElement {
    .init(
        geometry: .init(
            center: center,
            radius: radius
        ),
        material: MaterialMapEnum.default.rawValue
    )
}

private func makeFloorPlane() -> PlaneElement {
    PlaneRaytracingElement(
        geometry: .init(point: .zero, normal: .unitZ),
        material: MaterialMapEnum.floor.rawValue
    )
}

private enum MaterialMapEnum: Int, CaseIterable, MaterialMapEnumType {
    case `default` = 0
    case floor = 1

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
        }
    }
}
