import Foundation
#if canImport(Geometria)
import Geometria
#endif

enum RaymarchingHyperplanePolyhedronScene {
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
    
    makeTetrahedron(
        center: .init(x: 0, y: 80, z: 40),
        edgeLength: 40,
        material: .glassy
    )

    makeDodecahedron(
        center: .init(x: 80, y: 80, z: 40),
        edgeLength: 20,
        material: .glassy
    )
}

private func makeTetrahedron(center: RVector3D, edgeLength: Double, material: MaterialMapEnum = .glassy) -> some RaymarchingBoundedElement {
    let insphereRadius = edgeLength / 24.0.squareRoot()
    let circumscribedRadius = edgeLength * (6.0.squareRoot() / 4.0)

    let rot = toRadians(360 / 3)
    let dihedralAngle = acos(1.0 / 3.0)
    let faceElevation = .pi / 2 - dihedralAngle

    func hyper(azimuth: Double, elevation: Double) -> HyperplaneRaymarchingElement {
        let unit = RSphere3D.unit
        let normal = unit.projectOut(.init(azimuth: azimuth, elevation: elevation))

        return hyper(normal: normal)
    }
    func hyper(normal: RVector3D) -> HyperplaneRaymarchingElement {
        return makeHyper(
            point: center + normal * insphereRadius,
            normal: normal,
            material: material
        )
    }

    return intersection {
        hyper(azimuth: 0, elevation: faceElevation)
        hyper(azimuth: rot, elevation: faceElevation)
        hyper(azimuth: rot * 2, elevation: faceElevation)
        hyper(normal: -.unitZ)
    }.makeBounded(by:
        RSphere3D(center: center, radius: circumscribedRadius)
    )
}

private func makeDodecahedron(center: RVector3D, edgeLength: Double, material: MaterialMapEnum = .glassy) -> some RaymarchingBoundedElement {
    let insphereRadius: Double = (edgeLength / 2.0) * (5.0 / 2.0 + (11.0 / 10.0) * 5.0.squareRoot()).squareRoot()
    let circumscribedRadius: Double = edgeLength * (3.0.squareRoot() / 4.0) * (1.0 + 5.0.squareRoot())

    let rot = toRadians(360 / 5)
    let dihedralAngle = acos(-1.0 / 5.0.squareRoot())
    let faceElevation = .pi / 2 - dihedralAngle

    func hyper(azimuth: Double, elevation: Double) -> HyperplaneRaymarchingElement {
        let unit = RSphere3D.unit
        let normal = unit.projectOut(.init(azimuth: azimuth, elevation: elevation))

        return hyper(normal: normal)
    }
    func hyper(normal: RVector3D) -> HyperplaneRaymarchingElement {
        return makeHyper(
            point: center + normal * insphereRadius,
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
    }.makeBounded(by:
        RSphere3D(center: center, radius: circumscribedRadius)
    )
}

private func makeHyper(point: RVector3D, normal: RVector3D, material: MaterialMapEnum = .glassy) -> HyperplaneRaymarchingElement {
    HyperplaneRaymarchingElement(
        geometry: RHyperplane3D(
            point: point,
            normal: normal
        ),
        material: material.rawValue
    )
}

private func makeFloorPlane() -> PlaneRaymarchingElement {
    PlaneRaymarchingElement(
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
    case transparent = 3

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
            
        case .transparent:
            return .diffuse(
                .init(
                    color: .init(r: 128, g: 128, b: 128, a: 255),
                    transparency: 0.9
                )
            )
        }
    }
}
