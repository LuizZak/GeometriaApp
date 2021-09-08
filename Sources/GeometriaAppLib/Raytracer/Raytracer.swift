import SwiftBlend2D
import Geometria

/// Class that performs raytracing on a scene.
class Raytracer {
    private var processingPrinter: ProcessingPrinter?
    
    var maxBounces: Int = 5
    var scene: Scene
    var camera: Camera
    var viewportSize: Vector2i
    
    init(scene: Scene, camera: Camera, viewportSize: Vector2i) {
        self.scene = scene
        self.camera = camera
        self.viewportSize = viewportSize
    }
    
    // MARK: - Debugging
    
    func beginDebug() {
        processingPrinter = ProcessingPrinter()
    }
    
    func endDebug() {
        processingPrinter?.printAll()
        processingPrinter = nil
    }
    
    // MARK: - Ray Casting
    
    /// Does raycasting for a single pixel, returning the resulting color.
    func raytrace(pixelAt coord: Vector2i) -> BLRgba32 {
        assert(coord >= .zero && coord < viewportSize, "\(coord) is not within \(Vector2i.zero) x \(viewportSize) limits")
        
        let ray = camera.rayFromCamera(at: coord)
        return raytrace(ray: ray)
    }
    
    private func raytrace(ray: RRay3D, ignoring: RayIgnore = .none, bounceCount: Int = 0) -> BLRgba32 {
        if bounceCount >= maxBounces {
            return scene.skyColor
        }
        
        guard let hit = scene.intersect(ray: ray, ignoring: ignoring) else {
            processingPrinter?.add(ray: ray)
            return scene.skyColor
        }
        
        processingPrinter?.add(hit: hit, ray: ray)
        processingPrinter?.add(geometry: hit.sceneGeometry)
        processingPrinter?.add(intersection: hit.intersection)
        
        let geometry = hit.sceneGeometry.geometry
        let material = hit.sceneGeometry.material
        var color = material.color
        var minimumShade: Double = 0.0
        
        if geometry is RPlane3D {
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
        } else if let disk = geometry as? Disk3<RVector3D> {
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
        
        // Find rates for reflection and transmission within material
        let (refl, trans) = fresnel(ray.direction, hit.normal, material.refractiveIndex)
        
        // Reflectivity
        if material.reflectivity > 0.0 && bounceCount < maxBounces {
            // Raycast from normal and fade in the reflected color
            let reflection = reflect(direction: ray.direction, normal: hit.normal)
            let normRay = RRay3D(start: hit.point, direction: reflection)
            let secondHit = raytrace(ray: normRay,
                                     ignoring: .full(hit.sceneGeometry),
                                     bounceCount: bounceCount + 1)
            
            let factor: Double
            if material.refractiveIndex != 1.0 {
                factor = refl
            } else {
                factor = refl + material.reflectivity
            }
            
            color = color.faded(towards: secondHit, factor: Float(factor))
        }
        
        // Shadow or sunlight
        let shadow = calculateShadow(for: hit)
        if shadow > 0 {
            // Shadow
            color = color.faded(towards: .black, factor: Float(0.5 * shadow))
        } else {
            // Sunlight direction
            let sunDirDot = max(0.0, min(1, pow(hit.normal.dot(-scene.sunDirection), 5)))
            color = color.faded(towards: .white, factor: Float(sunDirDot))
        }
        
        // Transparency / refraction
        if material.transparency > 0.0 {
            // Raycast past geometry and add color
            var rayThroughObject: RRay3D = RRay3D(start: hit.point, direction: ray.direction)
            
            // If refraction is active, create a ray that points to the exit
            // point of the refracted ray that was generated inside the object's
            // geometry.
        refraction:
            if trans > 0 {
                guard let refractIn = refract(ray.direction, hit.normal, material.refractiveIndex) else {
                    break refraction
                }
                
                // Ray that traverses within the geometry
                let innerRay = RRay3D(start: hit.point, direction: refractIn)
                
                guard let exit = hit.sceneGeometry.doRayCast(ray: innerRay, ignoring: .entrance(hit.sceneGeometry)) else {
                    processingPrinter?.add(ray: innerRay)
                    break refraction
                }
                
                processingPrinter?.add(hit: exit, ray: innerRay)
                
                // Note that we must negate exit normal since exit normals
                // normally point to the inside of the shape.
                guard let refractOut = refract(innerRay.direction,
                                               -exit.normal,
                                               material.refractiveIndex) else {
                    break refraction
                }
                
                rayThroughObject = RRay3D(start: exit.point, direction: refractOut)
            }
            
            let backColor = raytrace(ray: rayThroughObject,
                                     ignoring: .full(hit.sceneGeometry),
                                     bounceCount: bounceCount)
            color = color.faded(towards: backColor, factor: Float(material.transparency * trans))
        }
        
        // Fade distant pixels to skyColor
        let far = 1000.0
        let dist = ray.a.distanceSquared(to: hit.point)
        let distFactor = max(0, min(1, Float(dist / (far * far))))
        color = color.faded(towards: scene.skyColor, factor: distFactor)
        
        return color
    }
    
    /// Reflects an incoming direction across a normal, returning a new direction
    /// such that the angle between `direction <- normal` is the same as
    /// `normal -> result`.
    private func reflect(direction: RVector3D, normal: RVector3D) -> RVector3D {
        // R = D - 2(D • N)N
        return direction - 2 * direction.dot(normal) * normal
    }
    
    /// Calculates shadow ratio. 0 = no shadow, 1 = fully shadowed, values in
    /// between specify the percentage of opaqueness of geometry obstructing the
    /// ray.
    ///
    /// Transparent geometries contributed a weighted value that is relative
    /// to how opaque they are.
    private func calculateShadow(for hit: RayHit) -> Double {
        func opaqueness(ray: RRay3D, ignoring: RayIgnore) -> Double {
            let transparency =
            scene.intersectAll(ray: ray, ignoring: ignoring)
                .map(\.sceneGeometry.material.transparency)
                .reduce(1.0, *)
            
            return max(0.0, min(1.0, 1 - transparency))
        }
        
        let ray = RRay3D(start: hit.point, direction: -scene.sunDirection)
        
        return opaqueness(ray: ray, ignoring: .full(hit.sceneGeometry))
    }
}

// MARK: Following functions for refraction angle and fresnel equations where sourced from:
// https://www.scratchapixel.com/lessons/3d-basic-rendering/introduction-to-shading/reflection-refraction-fresnel

/// Figure out refraction angle
///
/// - Parameters:
///   - I: Incidence angle (angle of incoming ray)
///   - N: Normal at surface of object
///   - ior: Index of refraction of material
///
/// - Returns: Angle for ray cast to within the object
func refract(_ I: RVector3D, _ N: RVector3D, _ ior: Double) -> RVector3D? {
    var cosi: Double = max(-1, min(1, I.dot(N)))
    var etai: Double = 1.0, etat = ior
    var n = N
    if cosi < 0 {
        cosi = -cosi
    } else {
        swap(&etai, &etat)
        n = -N
    }
    let eta = etai / etat
    let denom: Double = eta * eta
    let k: Double = 1 - denom * (1 - cosi * cosi)
    if k < 0 {
        return nil
    }
    let resultHalf: RVector3D = eta * I
    let resultLast: RVector3D = (eta * cosi - sqrt(k)) * n
    
    return resultHalf + resultLast
}

/// Uses the [Fresnel equations](https://en.wikipedia.org/wiki/Fresnel_equations)
/// to compute the rate of reflection / transmittance (refraction) within a material.
///
/// - Parameters:
///   - I: Incidence angle (angle of incoming ray)
///   - N: Normal at surface of object
///   - ior: Index of refraction of material
///
/// - Returns: A tuple of values, adding up to 1.0, which describe the rate of
/// the light that should be reflected vs transmitted (refracted) within.
func fresnel(_ I: RVector3D, _ N: RVector3D, _ ior: Double) -> (reflection: Double, transmittance: Double) {
    var cosi: Double = max(-1, min(1, I.dot(N)))
    var etai: Double = 1.0, etat = ior
    if cosi > 0 {
        swap(&etai, &etat)
    }
    
    // Compute sini using Snell's law
    let sint: Double = etai / etat * sqrt(max(0.0, 1 - cosi * cosi))
    
    // Total internal reflection
    if sint >= 1 {
        return (1, 0)
    } else {
        let cost: Double = sqrt(max(0.0, 1 - sint * sint))
        cosi = abs(cosi)
        let Rs: Double = ((etat * cosi) - (etai * cost)) / ((etat * cosi) + (etai * cost))
        let Rp: Double = ((etai * cosi) - (etat * cost)) / ((etai * cosi) + (etat * cost))
        let refl = (Rs * Rs + Rp * Rp) / 2
        
        return (refl, 1 - refl)
    }
}
