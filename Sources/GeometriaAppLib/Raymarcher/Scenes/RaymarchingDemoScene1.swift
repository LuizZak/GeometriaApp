enum RaymarchingDemoScene1 {
    static func makeScene() -> some RaymarchingSceneType {
        // TODO: Add support for materials
        RaymarchingElementBuilder.makeScene(skyColor: .cornflowerBlue) {
            // Back AABB
            (
                RAABB3D(minimum: .init(x: -50, y: 200, z: 10),
                        maximum: .init(x: 0, y: 210, z: 50)),
                
                RaymarcherMaterial.solid(.indianRed)
            )
            
            // Top AABB
            RAABB3D(minimum: .init(x: -70, y: 120, z: 60),
                    maximum: .init(x: 10, y: 140, z: 112))
            
            makeShinySphere()
            makeCylinder()
            makeBumpySphere()

            // TODO: Implement ellipse distance function and re-add this
            
            /*
            // Ellipse
            (
                REllipse3D(center: .init(x: -50, y: 90, z: 20),
                           radius: .init(x: 20, y: 15, z: 10)),
                
                Material(reflectivity: 0.5)
            )
            */
            
            makeDisk()
            makeFloorPlane()
        }
    }

    @RaymarchingElementBuilder
    private static func makeShinySphere() -> some RaymarchingElement {
        (
            RSphere3D(center: .init(x: 0, y: 150, z: 45), radius: 30) //,
            
            // TODO: Add reflective material
            /*
            Material(color: .gray,
                        reflectivity: 0.6,
                        transparency: 1.0,
                        refractiveIndex: 1.3)
            */
        )
    }

    @RaymarchingElementBuilder
    private static func makeCylinder() -> some RaymarchingElement {
        (
            RCylinder3D(start: .init(x: 60, y: 150, z: 0),
                            end: .init(x: 60, y: 150, z: 100),
                            radius: 20),
            
            RaymarcherMaterial.solid(.init(r: 128, g: 128, b: 128, a: 255))

            // TODO: Add refractive material
            /*
            Material(color: .init(r: 128, g: 128, b: 128, a: 255),
                        bumpNoiseFrequency: 1.0,
                        bumpMagnitude: 0.0,
                        reflectivity: 0.0,
                        transparency: 1.0,
                        refractiveIndex: 1.3)
            */
        )
    }

    @RaymarchingElementBuilder
    private static func makeBumpySphere() -> some RaymarchingElement {
        (
            RSphere3D(center: .init(x: 70, y: 150, z: 45), radius: 30)

            // TOOD: Add bumpy material
            /*
            Material(bumpNoiseFrequency: 1.0,
                        bumpMagnitude: 1.0 / 40.0,
                        reflectivity: 0.4)
            */
        )
    }

    @RaymarchingElementBuilder
    private static func makeDisk() -> some RaymarchingElement {
        (
            RDisk3D(center: .init(x: -10, y: 110, z: 20),
                    normal: .unitY,
                    radius: 12),

            RaymarcherMaterial.target(center: .init(x: -10, y: 110, z: 20), stripeFrequency: 5.0, color1: .red, color2: .white)
        )
    }

    @RaymarchingElementBuilder
    private static func makeFloorPlane() -> some RaymarchingElement {
        (
            RPlane3D(point: .zero, normal: .unitZ),

            RaymarcherMaterial.checkerboard(size: 50.0, color1: .white, color2: .black)
        )
    }
}
