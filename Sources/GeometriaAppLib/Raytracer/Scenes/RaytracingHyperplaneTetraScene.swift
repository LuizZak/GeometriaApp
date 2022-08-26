enum RaytracingHyperplaneTetraScene {
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
    
    makeTetrahedron(
        center: .init(x: 0, y: 80, z: 40),
        length: 20,
        material: .glassy
    )

    makeDodecahedron(
        center: .init(x: 80, y: 80, z: 40),
        faceRadius: 20,
        material: .glassy
    )
}

private func makeTetrahedron(center: RVector3D, length: Double, material: MaterialMapEnum = .glassy) -> some RaytracingElement {
    let offset = length / 2
    
    let rot = RRotationMatrix3D.make3DRotationFromAxisAngle(axis: RVector3D.unitZ, toRadians(-15))
    
    let mat1 = RRotationMatrix3D.make3DRotationFromAxisAngle(axis: RVector3D.unitZ, toRadians(120))
    let mat2 = RRotationMatrix3D.make3DRotationFromAxisAngle(axis: RVector3D.unitZ, toRadians(240))
    
    let normSide = rot.transformPoint(RVector3D(x: 2, y: 0, z: 1).normalized())
    let norm1 = normSide
    let norm2 = mat1.transformPoint(normSide)
    let norm3 = mat2.transformPoint(normSide)
    
    return intersection {
        makeHyper(
            point: center - .unitZ * offset,
            normal: -.unitZ,
            material: material
        )
        makeHyper(
            point: center + norm1 * offset,
            normal: norm1,
            material: material
        )
        makeHyper(
            point: center + norm2 * offset,
            normal: norm2,
            material: material
        )
        makeHyper(
            point: center + norm3 * offset,
            normal: norm3,
            material: material
        )
    }
}

private func makeDodecahedron(center: RVector3D, faceRadius: Double, material: MaterialMapEnum = .glassy) -> some RaytracingElement {
    let offset = faceRadius

    let rot = toRadians(360 / 5)
    let dihedralAngle = toRadians(116.56505)
    let faceElevation = .pi / 2 - dihedralAngle

    func hyper(azimuth: Double, elevation: Double) -> HyperplaneRaytracingElement {
        let unit = RSphere3D.unit
        let normal = unit.projectOut(.init(azimuth: azimuth, elevation: elevation))

        return hyper(normal: normal)
    }
    func hyper(normal: RVector3D) -> HyperplaneRaytracingElement {
        return makeHyper(
            point: center + normal * offset,
            normal: normal,
            material: material
        )
    }

    let top = intersection {
        hyper(normal: .unitZ)
        hyper(azimuth: 0, elevation: faceElevation)
        hyper(azimuth: rot, elevation: faceElevation)
        hyper(azimuth: rot * 2, elevation: faceElevation)
        hyper(azimuth: rot * 3, elevation: faceElevation)
        hyper(azimuth: rot * 4, elevation: faceElevation)
    }

    let bottom = intersection {
        let halfRot = rot / 2

        hyper(normal: -.unitZ)
        hyper(azimuth: halfRot, elevation: -faceElevation)
        hyper(azimuth: halfRot + rot, elevation: -faceElevation)
        hyper(azimuth: halfRot + rot * 2, elevation: -faceElevation)
        hyper(azimuth: halfRot + rot * 3, elevation: -faceElevation)
        hyper(azimuth: halfRot + rot * 4, elevation: -faceElevation)
    }

    return intersection {
        top
        bottom
    }.makeBounded(by: .init(
        minimum: center - .one * faceRadius,
        maximum: center + .one * faceRadius
    ))
}

private func makeHyper(point: RVector3D, normal: RVector3D, material: MaterialMapEnum = .glassy) -> HyperplaneRaytracingElement {
    HyperplaneRaytracingElement(
        geometry: RHyperplane3D(
            point: point,
            normal: normal
        ),
        material: material.rawValue
    )
}

private func makeFloorPlane() -> PlaneRaytracingElement {
    PlaneRaytracingElement(
        geometry: .init(point: .zero, normal: .unitZ),
        material: MaterialMapEnum.floor.rawValue
    )
}

private func toRadians(_ angleInDegrees: Double) -> Double {
    angleInDegrees * (.pi / 180)
}

private enum MaterialMapEnum: Int, CaseIterable, MaterialMapEnumType {
    case `default` = 0
    case floor = 1
    case glassy = 2

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
            
        case .glassy:
            return .diffuse(
                .init(
                    color: .init(r: 128, g: 128, b: 128, a: 255),
                    reflectivity: 0.3,
                    transparency: 0.9,
                    refractiveIndex: 1.3
                )
            )
        }
    }
}
