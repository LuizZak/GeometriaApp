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
    
    translated(x: 0, y: -20, z: 30) {
        makeTetrahedron(
            center: .init(x: 0, y: 100, z: 40),
            length: 30
        )
    }
}

private func makeTetrahedron(center: RVector3D, length: Double) -> some RaytracingElement {
    let offset = length / 2
    
    let rot = RRotationMatrix3D.make3DRotationFromAxisAngle(axis: RVector3D.unitZ, -15 * (.pi / 180))
    
    let mat1 = RRotationMatrix3D.make3DRotationFromAxisAngle(axis: RVector3D.unitZ, 120 * (.pi / 180))
    let mat2 = RRotationMatrix3D.make3DRotationFromAxisAngle(axis: RVector3D.unitZ, 240 * (.pi / 180))
    
    let normSide = rot.transformPoint(RVector3D(x: 2, y: 0, z: 1).normalized())
    let norm1 = normSide
    let norm2 = mat1.transformPoint(normSide)
    let norm3 = mat2.transformPoint(normSide)
    
    return intersection {
        makeHyper(
            point: center - .unitZ * offset,
            normal: -.unitZ
        )
        makeHyper(
            point: center + norm1 * offset,
            normal: norm1
        )
        makeHyper(
            point: center + norm2 * offset,
            normal: norm2
        )
        makeHyper(
            point: center + norm3 * offset,
            normal: norm3
        )
    }
}

private func makeHyper(point: RVector3D, normal: RVector3D) -> HyperplaneRaytracingElement {
    HyperplaneRaytracingElement(
        geometry: RHyperplane3D(
            point: point,
            normal: normal
        ),
        material: MaterialMapEnum.glassy.rawValue
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
