#if canImport(Geometria)
import Geometria
#endif

enum RaytracingDemoScene4 {
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

    rotated(by: .make3DRotationY(.pi / 2), around: .init(x: 0, y: 100, z: 40)) {
        rotated(by: .make3DRotationZ(.pi / 4), around: .init(x: 0, y: 100, z: 40)) {
            makeCylinder(
                center: .init(x: 0, y: 100, z: 40),
                direction: .unitZ,
                length: 40,
                radius: 10
            )
        }
    }
}

@_transparent
private func makeCylinder(
    center: RVector3D,
    direction: RVector3D,
    length: Double,
    radius: Double
) -> CylinderElement {
    
    let start = center - direction * length / 2
    let end = center + direction * length / 2

    return .init(
        geometry: .init(
            start: start,
            end: end,
            radius: radius
        ),
        material: MaterialMapEnum.transparent.rawValue
    )
}

private func makeFloorPlane() -> PlaneElement {
    PlaneRaytracingElement(
        geometry: .init(point: .zero, normal: .unitZ),
        material: MaterialMapEnum.floor.rawValue
    )
}

private enum MaterialMapEnum: Int, CaseIterable, MaterialMapEnumType {
    case `default`
    case floor
    case shiny
    case transparent

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

        case .shiny:
            return .diffuse(
                .init(
                    color: .gray,
                    reflectivity: 0.8,
                    transparency: 0.9,
                    refractiveIndex: 1.3
                )
            )

        case .transparent:
            return .diffuse(
                .init(
                    color: .gray,
                    transparency: 0.2
                )
            )
        }
    }
}
