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
    
    translated(x: 0, y: -80, z: 30) {
        makeTetrahedron(
            center: .init(x: 0, y: 100, z: 40),
            length: 30
        )
    }
}

private func makeTetrahedron(center: RVector3D, length: Double) -> some RaytracingElement {
    let offset = length / 2
    let normSide = RVector3D(x: 0, y: 1, z: -1).normalized()
    let mat = RRotationMatrix3D.make3DRotationFromAxisAngle(axis: RVector3D.unitZ, 120)
    
    let norm1 = normSide
    let norm2 = mat.transformPoint(norm1)
    let norm3 = mat.transformPoint(norm2)
    
    return intersection {
        makeHyper(point: center + .unitX * 10, normal: .unitX)
        makeHyper(point: center - .unitX * 10, normal: -.unitX)
    }
    
    /*
    return intersection {
        makeHyper(
            point: center - .unitZ * offset,
            normal: -.unitZ
        )
        makeHyper(
            point: center + norm1 * offset,
            normal: norm1
        )
        /*
        makeHyper(
            point: center + norm2 * offset,
            normal: norm2
        )
        makeHyper(
            point: center + norm3 * offset,
            normal: norm3
        )*/
    }
    */
}

private func makeHyper(point: RVector3D, normal: RVector3D) -> HyperplaneRaytracingElement {
    HyperplaneRaytracingElement(
        geometry: RHyperplane3D(
            point: point,
            normal: normal
        ),
        material: MaterialMapEnum.default.rawValue
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
