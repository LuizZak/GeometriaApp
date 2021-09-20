enum DemoScene {
    static func makeScene() -> Scene {
        SceneBuilder.makeScene {
            // Back AABB
            (
                RAABB3D(minimum: .init(x: -50, y: 200, z: 10),
                        maximum: .init(x: 0, y: 210, z: 50)),
                Material(color: .indianRed)
            )
            
            // Top AABB
            (
                RAABB3D(minimum: .init(x: -70, y: 120, z: 60),
                        maximum: .init(x: 10, y: 140, z: 112))
            )
            
            // Shiny Sphere
            (
                RSphere3D(center: .init(x: 0, y: 150, z: 45), radius: 30),
                
                Material(color: .gray,
                         reflectivity: 0.6,
                         transparency: 1.0,
                         refractiveIndex: 1.3)
            )
            
            // Cylinder
            (
                RCylinder3D(start: .init(x: 60, y: 150, z: 0),
                            end: .init(x: 60, y: 150, z: 100),
                            radius: 20),
                
                Material(color: .init(r: 128, g: 128, b: 128, a: 255),
                         bumpNoiseFrequency: 1.0,
                         bumpMagnitude: 0.0,
                         reflectivity: 0.0,
                         transparency: 1.0,
                         refractiveIndex: 1.3)
            )
            
            // Bumpy Sphere
            SceneGeometry(
                bumpySphere: .init(center: .init(x: 70, y: 150, z: 45), radius: 30),
                material: .init(bumpNoiseFrequency: 1.0,
                                bumpMagnitude: 1.0 / 40.0,
                                reflectivity: 0.4)
            )
            
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
