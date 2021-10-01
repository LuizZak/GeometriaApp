import SwiftBlend2D

@resultBuilder
struct SceneBuilder {
    static func buildFinalResult(_ component: PartialScene) -> Scene {
        var scene = Scene()
        if let skyColor = component.skyColor {
            scene.skyColor = skyColor
        }
        if let sunDirection = component.sunDirection {
            scene.sunDirection = sunDirection
        }
        for geo in component.geometries {
            scene.addGeometry(geo)
        }
        return scene
    }
    
    static func buildExpression<C: Convex3Type & SignedDistanceMeasurableType & BoundableType>(_ expression: C) -> PartialScene where C.Vector == RVector3D {
        SceneGeometry(id: 0, convex3: expression, material: .default, useBoundSphere: true).toPartialScene()
    }
    
    static func buildExpression<C: Convex3Type & SignedDistanceMeasurableType & BoundableType>(_ expression: (C, Material)) -> PartialScene where C.Vector == RVector3D {
        SceneGeometry(id: 0, convex3: expression.0, material: expression.1, useBoundSphere: true).toPartialScene()
    }
    
    static func buildExpression(_ expression: RDisk3D) -> PartialScene {
        SceneGeometry(id: 0, boundedPlane: expression, material: .default).toPartialScene()
    }
    
    static func buildExpression(_ expression: (RDisk3D, Material)) -> PartialScene {
        SceneGeometry(id: 0, boundedPlane: expression.0, material: expression.1).toPartialScene()
    }
    
    static func buildExpression(_ expression: RPlane3D) -> PartialScene {
        SceneGeometry(id: 0, plane: expression, material: .default).toPartialScene()
    }
    
    static func buildExpression(_ expression: (RPlane3D, Material)) -> PartialScene {
        SceneGeometry(id: 0, plane: expression.0, material: expression.1).toPartialScene()
    }
    
    static func buildExpression(_ expression: SceneGeometry) -> PartialScene {
        PartialScene(skyColor: nil, geometries: [expression])
    }
    
    static func buildBlock(_ components: PartialScene...) -> PartialScene {
        if components.isEmpty {
            return PartialScene()
        }
        
        return components.reduce(PartialScene(), { $0.merge($1) })
    }
}

private extension SceneGeometry {
    func toPartialScene() -> PartialScene {
        return PartialScene(geometries: [self])
    }
}

struct PartialScene {
    var skyColor: BLRgba32?
    var sunDirection: RVector3D?
    var geometries: [SceneGeometry] = []
    
    func merge(_ other: PartialScene) -> PartialScene {
        PartialScene(skyColor: skyColor ?? other.skyColor,
                     sunDirection: sunDirection ?? other.sunDirection,
                     geometries: geometries + other.geometries)
    }
}

extension SceneBuilder {
    static func makeScene(@SceneBuilder _ builder: () -> Scene) -> Scene {
        var scene = builder()
        for index in 0..<scene.geometries.count {
            scene.geometries[index].id = index + 1
        }

        return scene
    }
}
