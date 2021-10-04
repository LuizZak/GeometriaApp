import SwiftBlend2D

enum RaymarchingDemoScene2 {
    static func makeScene() -> some RaymarchingSceneType {
        RaymarchingElementBuilder.makeScene(skyColor: .cornflowerBlue) {
            scene()
        }
    }
}

@RaymarchingElementBuilder
private func scene() -> some RaymarchingElement {
    makeFloorPlane()

    makeGreekBuilding(withBaseCenteredAt: .init(x: 0, y: 300, z: 0))
}

private func makeGreekBuilding(withBaseCenteredAt point: RVector3D) -> some BoundedRaymarchingElement {
    let building = group {
        let pillars = makePillar(
            at: .init(x: 0, y: 0, z: 0),
            height: 80,
            radius: 7
        )
        .repeatTranslated(count: 10, translation: .unitX * 30).makeBoundingBox()
        .repeatTranslated(count: 2, translation: .unitY * 150).makeBoundingBox()

        let pillarBounds = pillars.makeBounds()

        let baseSize = pillarBounds.size.take.xy + .init(x: 5, y: 5)

        makeBase(
            center: .init(pillarBounds.center.take.xy),
            size: baseSize
        )

        makeTop(
            center: .init(pillarBounds.center.take.xy, z: pillarBounds.maximum.z),
            size: baseSize
        )
        
        pillars
    }
    
    return building.centered(at: .init(point.take.xy, z: point.z + building.makeBounds().size.z / 2)).makeBoundingBox()
}

@RaymarchingElementBuilder
private func makeBase(center: RVector3D, size: RVector2D) -> some BoundedRaymarchingElement {
    let sizeIncrease = RVector3D(x: 5, y: 5, z: 0)
    let translation = RVector3D(x: 0, y: 0, z: -5)

    boundingBox {
        makeAABB(center: center + translation * 0, size: .init(size, z: 5) + sizeIncrease * 0)
        makeAABB(center: center + translation * 1, size: .init(size, z: 5) + sizeIncrease * 1)
        makeAABB(center: center + translation * 2, size: .init(size, z: 5) + sizeIncrease * 2)
        makeAABB(center: center + translation * 3, size: .init(size, z: 5) + sizeIncrease * 3)
        makeAABB(center: center + translation * 4, size: .init(size, z: 5) + sizeIncrease * 4)
    }
}
@RaymarchingElementBuilder
private func makeTop(center: RVector3D, size: RVector2D) -> some BoundedRaymarchingElement {
    let sizeIncrease = RVector3D(x: 5, y: 5, z: 0)
    let translation = RVector3D(x: 0, y: 0, z: 5)

    boundingBox {
        makeAABB(center: center + translation * 0, size: .init(size, z: 5) + sizeIncrease * 0)
        makeAABB(center: center + translation * 1, size: .init(size, z: 5) + sizeIncrease * 1)
        makeAABB(center: center + translation * 2, size: .init(size, z: 5) + sizeIncrease * 2)
    }
}

private func makePillar(at point: RVector3D, height: Double, radius: Double) -> some BoundedRaymarchingElement {
    let start = point
    let end = point + .unitZ * height

    let mainCylinder = cylinder(start: start, end: end, radius: radius, color: .white)

    return boundingBox {
        cylinder(start: start, end: start + .unitZ * 5, radius: radius + 1, color: .white)
        cylinder(start: end, end: end - .unitZ * 5, radius: radius + 1, color: .white)

        PillarWaveRaymarchingElement(element: mainCylinder)
        //mainCylinder
    }
}

private func cylinder(start: RVector3D, end: RVector3D, radius: Double, color: BLRgba32 = .gray) -> CylinderRaymarchingElement {
    CylinderRaymarchingElement(
        geometry: .init(start: start, end: end, radius: radius),
        material: .solid(color)
    )
}

private func makeAABB(center: RVector3D, size: RVector3D) -> AABBRaymarchingElement {
    AABBRaymarchingElement(
        geometry: .init(minimum: center - size / 2, maximum: center + size / 2),
        material: .solid(.white)
    )
}

private func makeFloorPlane() -> PlaneRaymarchingElement {
    PlaneRaymarchingElement(
        geometry: .init(point: .zero, normal: .unitZ),
        material: .checkerboard(size: 50.0, color1: .white, color2: .black)
    )
}

private struct PillarWaveRaymarchingElement: BoundedRaymarchingElement {
    var element: CylinderRaymarchingElement
    var line: RLineSegment3D
    var magnitude: Double

    init(element: CylinderRaymarchingElement) {
        self.element = element
        self.line = element.geometry.asLineSegment
        self.magnitude = element.geometry.radius
    }

    @inline(never)
    func signedDistance(to point: RVector3D, current: RaymarchingResult) -> RaymarchingResult {
        let mag = line.projectAsScalar(point)
        if !line.containsProjectedNormalizedMagnitude(mag) {
            return element.signedDistance(to: point, current: current)
        }

        let projected = line.projectedNormalizedMagnitude(mag)
        let projectedLine = RLineSegment2D(start: projected, end: point)
        
        let diff = point - projected
        let distToCenter = diff.length
        let angle = diff.take.xy.angle
        let c = cos(angle)
        let s = sin(angle)

        let x = c * element.geometry.radius
        let y = s * element.geometry.radius

        let p = projected + RVector3D(x: x, y: y, z: point.z)

        let distToSurface = p.distance(to: point)
        let result = distToCenter < element.geometry.radius ? -distToSurface : distToSurface

        return RaymarchingResult(distance: result, material: element.material)

        //return element.signedDistance(to: point, current: current)
        /*
        let projected = line.project(point)
        let diff = point - projected
        let angle = diff.take.xy.angle
        let c = cos(angle * 10)

        var cyl = element.signedDistance(to: point, current: current)
        if cyl.distance >= current.distance {
            return cyl
        }

        cyl.distance *= 1.1
        
        return cyl
        */
    }

    @_transparent 
    func makeBounds() -> RaymarchingBounds {
        element.makeBounds()
    }
}
