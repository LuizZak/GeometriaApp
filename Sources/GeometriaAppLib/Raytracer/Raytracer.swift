import SwiftBlend2D
import Geometria

/// Class that performs raytracing on a scene.
class Raytracer {
    var maxBounces: Int = 5
    var scene: Scene
    var camera: Camera
    var viewportSize: Vector2i
    
    init(scene: Scene, camera: Camera, viewportSize: Vector2i) {
        self.scene = scene
        self.camera = camera
        self.viewportSize = viewportSize
    }
    
    // MARK: - Ray Casting
    
    /// Does raycasting for a single pixel, returning the resulting color.
    func raytrace(pixelAt coord: Vector2i) -> BLRgba32 {
        assert(coord >= .zero && coord < viewportSize, "\(coord) is not within \(Vector2i.zero) x \(viewportSize) limits")
        
        let ray = camera.rayFromCamera(at: coord)
        return raytrace(ray: ray)
    }
    
    private func raytrace(ray: Ray, ignoring: GeometricType? = nil, bounceCount: Int = 0) -> BLRgba32 {
        if bounceCount >= maxBounces {
            return scene.skyColor
        }
        
        guard let hit = scene.intersect(ray: ray, ignoring: ignoring) else {
            return scene.skyColor
        }
        
        let material = hit.sceneGeometry.material
        var color = material.color
        var minimumShade: Double = 0.0
        
        if hit.geometry is Plane {
            minimumShade = 0.6
            
            let checkerSize = 50.0
            let checkerPhase = abs(hit.point) % checkerSize * 2
            
            var isWhite = false
            
            switch (checkerPhase.x, checkerPhase.y) {
            case (checkerSize..., checkerSize...), (0...checkerSize, 0...checkerSize):
                isWhite = false
            default:
                isWhite = true
            }
            
            if hit.point.x < 0 {
                isWhite.toggle()
            }
            if hit.point.y < 0 {
                isWhite.toggle()
            }
            
            color = isWhite ? .white : .black
        } else if let disk = hit.geometry as? Disk3<Vector3D> {
            // Distance at which the disk color changes from white to red.
            let stripeFrequency = 5.0
            let dist = hit.point.distance(to: disk.center)
            
            let phase = dist.truncatingRemainder(dividingBy: stripeFrequency)
            if phase < stripeFrequency / 2 {
                color = .red
            } else {
                color = .white
            }
        }
        
        // Shading
        let shade = max(0.0, min(1 - minimumShade, hit.normal.dot(-ray.direction)))
        color = color.faded(towards: .black, factor: Float(1 - shade))
        
        // Reflectivity
        if material.reflectivity > 0.0 && bounceCount < maxBounces {
            // Raycast from normal and fade in the reflected color
            let normRay = Ray(start: hit.point, direction: hit.normal)
            let secondHit = raytrace(ray: normRay, ignoring: hit.geometry, bounceCount: bounceCount + 1)
            color = color.faded(towards: secondHit, factor: Float(material.reflectivity))
        }
        
        // Shadow or sunlight
        let shadow = calculateShadow(hit: hit)
        if shadow > 0 {
            // Shadow
            color = color.faded(towards: .black, factor: Float(0.5 * shadow))
        } else {
            // Sunlight direction
            let sunDirDot = max(0.0, min(1, pow(hit.normal.dot(-scene.sunDirection), 5)))
            color = color.faded(towards: .white, factor: Float(sunDirDot))
        }
        
        // Fade distant pixels to skyColor
        let far = 1000.0
        let dist = ray.a.distanceSquared(to: hit.point)
        let distFactor = max(0, min(1, Float(dist / (far * far))))
        color = color.faded(towards: scene.skyColor, factor: distFactor)
        
        return color
    }
    
    /// Calculates shadow ratio. 0 = no shadow, 1 = fully shadowed, values in
    /// between specify the percentage of shadow rays that where obstructed by
    /// geometry.
    private func calculateShadow(hit: RayHit, rays: Int = 1) -> Double {
        if rays == 1 {
            let ray = Ray(start: hit.point, direction: -scene.sunDirection)
            if scene.intersect(ray: ray, ignoring: hit.geometry) != nil {
                return 1.0
            }
            
            return 0.0
        }
        
        let mag = 150.0
        var shadowsHit = 0.0
        
        for _ in 0..<rays {
            var shadowLine = Line3(a: hit.point, b: hit.point - scene.sunDirection * mag)
            shadowLine.b.x += Double.random(in: -1...1)
            shadowLine.b.y += Double.random(in: -1...1)
            shadowLine.b.z += Double.random(in: -1...1)
            
            let ray = Ray.init(shadowLine)
            if scene.intersect(ray: ray, ignoring: hit.geometry) != nil {
                shadowsHit += 1
            }
        }
        
        return shadowsHit / Double(rays)
    }
}
