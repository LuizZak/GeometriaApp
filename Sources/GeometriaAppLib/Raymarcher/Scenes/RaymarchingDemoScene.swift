enum RaymarchingDemoScene {
    static func makeScene() -> some RaymarchingSceneType {
        // TODO: Add support for materials
        RaymarchingSceneBuilder.makeScene {
            // Back AABB
            RAABB3D(minimum: .init(x: -50, y: 200, z: 10),
                    maximum: .init(x: 0, y: 210, z: 50))
            
            // Top AABB
            RAABB3D(minimum: .init(x: -70, y: 120, z: 60),
                    maximum: .init(x: 10, y: 140, z: 112))
            
            // Shiny Sphere
            RSphere3D(center: .init(x: 0, y: 150, z: 45), radius: 30)
            
            // Cylinder
            RCylinder3D(start: .init(x: 60, y: 150, z: 0),
                        end: .init(x: 60, y: 150, z: 100),
                        radius: 20)
            
            // Bumpy Sphere
            RSphere3D(center: .init(x: 70, y: 150, z: 45), radius: 30)
            /*
            SceneGeometry(
                id: 0,
                bumpySphere: .init(center: .init(x: 70, y: 150, z: 45), radius: 30),
                material: .init(bumpNoiseFrequency: 1.0,
                                bumpMagnitude: 1.0 / 40.0,
                                reflectivity: 0.4)
            )
            */
            
            // TODO: Implement ellipse distance function and re-add this
            
            /*
            // Ellipse
            (
                REllipse3D(center: .init(x: -50, y: 90, z: 20),
                           radius: .init(x: 20, y: 15, z: 10)),
                
                Material(reflectivity: 0.5)
            )
            */
            
            // Disk
            RDisk3D(center: .init(x: -10, y: 110, z: 20),
                    normal: .unitY,
                    radius: 12)
            
            // Floor plane
            RPlane3D(point: .zero, normal: .unitZ)
        }
    }
}
