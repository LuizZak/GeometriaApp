import SwiftBlend2D
import ImagineUI

/// Class that performs raytracing on a scene.
final class Raytracer: RendererType {
    private static var _attemptedDebugInMultithreadedYet = false
    private var processingPrinter: RaytracerProcessingPrinter?
    
    private let minimumRayToleranceSq: Double = 0.001
    
    /// Bias used when creating rays for refraction and reflection.
    private let bias: Double = 0.01
    
    var isMultiThreaded: Bool = false
    var maxBounces: Int = 15
    var scene: Scene
    var camera: Camera
    var viewportSize: ViewportSize
    
    init(scene: Scene, camera: Camera, viewportSize: ViewportSize) {
        self.scene = scene
        self.camera = camera
        self.viewportSize = viewportSize
    }
    
    // MARK: - Debugging
    
    func beginDebug() {
        if isMultiThreaded {
            if !Raytracer._attemptedDebugInMultithreadedYet {
                Raytracer._attemptedDebugInMultithreadedYet = true
                print("Attempted to invoke Raytracer.beginDebug() with a multi-pixel, multi-threaded render, which is potentially not intended. Ignoring...")
            }
            
            return
        }
        
        processingPrinter =
        RaytracerProcessingPrinter(
            viewportSize: RVector2D(viewportSize),
            sceneCamera: camera
        )
    }
    
    func endDebug() {
        processingPrinter?.printAll()
        processingPrinter = nil
    }
    
    // MARK: - Ray Casting
    
    /// Does raycasting for a single pixel, returning the resulting color.
    func render(pixelAt coord: PixelCoord) -> BLRgba32 {
        assert(coord >= .zero && coord < viewportSize, "\(coord) is not within \(PixelCoord.zero) x \(viewportSize) limits")
        
        let ray = camera.rayFromCamera(at: coord)
        return raytrace(ray: ray)
    }
    
    private func raytrace(ray: RRay3D, ignoring: RayIgnore = .none, bounceCount: Int = 0) -> BLRgba32 {
        if bounceCount >= maxBounces {
            return BLRgba32.transparentBlack
        }
        
        guard let hit = scene.intersect(ray: ray, ignoring: ignoring) else {
            processingPrinter?.add(ray: ray)
            return scene.skyColor
        }
        
        // Detect short distances that should avoid re-bounces
        var canRebounce = true
        switch ignoring {
        case .entrance(_, let minimumRayLengthSquared), .exit(_, let minimumRayLengthSquared):
            let dist = hit.pointOfInterest.point.distanceSquared(to: ray.start)
            if dist < minimumRayLengthSquared {
                processingPrinter?.add(ray: ray)
                canRebounce = false
            }
            
        default:
            break
        }

        let sceneGeometry = scene.geometries[hit.id]
        
        processingPrinter?.add(hit: hit, ray: ray)
        processingPrinter?.add(geometry: sceneGeometry)
        processingPrinter?.add(intersection: hit.intersection)
        
        let geometry = sceneGeometry.geometry
        let material = sceneGeometry.material
        let invTransparency = 1 - material.transparency
        var color = mergeColors(scene.skyColor, material.color, factor: invTransparency)
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
        color = mergeColors(color, .black, factor: (1 - shade) * invTransparency)
        
        // Find rates for reflection and transmission within material
        let (refl, trans) = fresnel(ray.direction, hit.normal, material.refractiveIndex)
        
        // Transparency / refraction
        if material.transparency > 0.0 {
            // Raycast past geometry and add color
            var rayThroughObject: RRay3D = RRay3D(start: hit.point, direction: ray.direction)
            var rayIgnore: RayIgnore = .full(id: hit.id)
            
            // If refraction is active, create a ray that points to the exit
            // point of the refracted ray that was generated inside the object's
            // geometry.
        refraction:
            if trans > 0 && canRebounce {
                guard let refractIn = refract(ray.direction, hit.normal, material.refractiveIndex) else {
                    break refraction
                }
                
                // TODO: Fix odd behavior of refraction where small internal
                // TODO: bounces of rays lead to incorrect pixels.
                
                // Ray that traverses within the geometry
                let innerRay = RRay3D(start: hit.point + hit.normal * bias, direction: refractIn)
                // Allow bouncing out of the geometry, but not in
                let minDist = 0.01
                let minDistSq = minDist * minDist
                rayIgnore = .entrance(id: hit.id, minimumRayLengthSquared: minDist * minDist)
                // Do a sanitity check that the ray isn't going to collide
                // immediately with the same geometry - if it does, skip the
                // geometry fully in the subsequent raycast
                let innerHit = sceneGeometry.doRayCast(ray: innerRay, ignoring: rayIgnore)
                if let innerHit = innerHit, innerHit.point.distanceSquared(to: hit.point) <= minDistSq {
                    rayIgnore = .full(id: hit.id)
                }
                
                rayThroughObject = innerRay
            }
            
            let backColor = raytrace(ray: rayThroughObject,
                                     ignoring: rayIgnore,
                                     bounceCount: bounceCount + 1)
            color = mergeColors(color, backColor, factor: material.transparency * trans)
        }
        
        // Reflectivity
        if material.reflectivity > 0.0 && bounceCount < maxBounces && canRebounce {
            // Raycast from normal and fade in the reflected color
            let ignoring: RayIgnore
            if hit.hitDirection == .inside {
                ignoring = .entrance(id: hit.id, minimumRayLengthSquared: minimumRayToleranceSq)
            } else {
                ignoring = .exit(id: hit.id, minimumRayLengthSquared: minimumRayToleranceSq)
            }
            let reflection = reflect(direction: ray.direction, normal: hit.normal)
            let normRay = RRay3D(start: hit.point, direction: reflection)
            let secondHit = raytrace(ray: normRay,
                                     ignoring: ignoring,
                                     bounceCount: bounceCount + 1)
            
            var factor: Double
            if material.refractiveIndex != 1.0 {
                factor = refl + (1 - material.transparency)
            } else {
                factor = refl + material.reflectivity
            }
            
            factor = max(0, min(1, factor))
            
            color = mergeColors(color, secondHit, factor: factor)
        }
        
        // TODO: Improve handling of shadow and direct light in refractive materials
        
        // Shadow or sunlight
        let shadow = calculateShadow(for: hit)
        if shadow > 0 {
            // Shadow
            color = mergeColors(color, .black, factor: 0.5 * shadow)
        } else {
            // Sunlight direction
            let sunDirDot = max(0.0, min(1, pow(hit.normal.dot(-scene.sunDirection), 5)))
            
            if material.hasRefraction {
                color = mergeColors(color, .white, factor: sunDirDot * refl)
            } else {
                color = mergeColors(color, .white, factor: sunDirDot)
            }
        }
        
        // Fade distant pixels to skyColor
        let far = 1000.0
        let dist = ray.a.distanceSquared(to: hit.point)
        let distFactor = max(0, min(1, dist / (far * far)))
        color = mergeColors(color, scene.skyColor, factor: distFactor)
        
        return color
    }
    
    private func computeColor(material: RaytracingMaterial,
                              ray: RRay3D,
                              hit: RayHit,
                              ignoring: RayIgnore = .none,
                              bounceCount: Int = 0) -> BLRgba32 {
        
        // Detect short distances that should avoid re-bounces
        var canRebounce = true
        switch ignoring {
        case .entrance(_, let minimumRayLengthSquared), .exit(_, let minimumRayLengthSquared):
            let dist = hit.pointOfInterest.point.distanceSquared(to: ray.start)
            if dist < minimumRayLengthSquared {
                canRebounce = false
            }
            
        default:
            break
        }
        
        var color: BLRgba32
        var minimumShade: Double = 0.0
        
        switch material {
        case .diffuse(let material):
            let sceneGeometry = scene.geometries[hit.id]
            
            let invTransparency = 1 - material.transparency
            color = mergeColors(scene.skyColor, material.color, factor: invTransparency)
            
            // Shading
            let shade = max(0.0, min(1 - minimumShade, hit.normal.dot(-ray.direction)))
            color = mergeColors(color, .black, factor: (1 - shade) * invTransparency)
            
            // Find rates for reflection and transmission within material
            let (refl, trans) = fresnel(ray.direction, hit.normal, material.refractiveIndex)
            
            // Transparency / refraction
            if material.transparency > 0.0 {
                // Raycast past geometry and add color
                var rayThroughObject: RRay3D = RRay3D(start: hit.point, direction: ray.direction)
                var rayIgnore: RayIgnore = .full(id: hit.id)
                
                // If refraction is active, create a ray that points to the exit
                // point of the refracted ray that was generated inside the object's
                // geometry.
            refraction:
                if trans > 0 && canRebounce {
                    guard let refractIn = refract(ray.direction, hit.normal, material.refractiveIndex) else {
                        break refraction
                    }
                    
                    // TODO: Fix odd behavior of refraction where small internal
                    // TODO: bounces of rays lead to incorrect pixels.
                    
                    // Ray that traverses within the geometry
                    let innerRay = RRay3D(start: hit.point + hit.normal * bias, direction: refractIn)
                    // Allow bouncing out of the geometry, but not in
                    let minDist = 0.01
                    let minDistSq = minDist * minDist
                    rayIgnore = .entrance(id: hit.id, minimumRayLengthSquared: minDist * minDist)
                    // Do a sanitity check that the ray isn't going to collide
                    // immediately with the same geometry - if it does, skip the
                    // geometry fully in the subsequent raycast
                    let innerHit = sceneGeometry.doRayCast(ray: innerRay, ignoring: rayIgnore)
                    if let innerHit = innerHit, innerHit.point.distanceSquared(to: hit.point) <= minDistSq {
                        rayIgnore = .full(id: hit.id)
                    }
                    
                    rayThroughObject = innerRay
                }
                
                let backColor = raytrace(ray: rayThroughObject,
                                         ignoring: rayIgnore,
                                         bounceCount: bounceCount + 1)
                color = mergeColors(color, backColor, factor: material.transparency * trans)
            }
            
            // Reflectivity
            if material.reflectivity > 0.0 && bounceCount < maxBounces && canRebounce {
                // Raycast from normal and fade in the reflected color
                let ignoring: RayIgnore
                if hit.hitDirection == .inside {
                    ignoring = .entrance(id: hit.id, minimumRayLengthSquared: minimumRayToleranceSq)
                } else {
                    ignoring = .exit(id: hit.id, minimumRayLengthSquared: minimumRayToleranceSq)
                }
                let reflection = reflect(direction: ray.direction, normal: hit.normal)
                let normRay = RRay3D(start: hit.point, direction: reflection)
                let secondHit = raytrace(ray: normRay,
                                         ignoring: ignoring,
                                         bounceCount: bounceCount + 1)
                
                var factor: Double
                if material.refractiveIndex != 1.0 {
                    factor = refl + (1 - material.transparency)
                } else {
                    factor = refl + material.reflectivity
                }
                
                factor = max(0, min(1, factor))
                
                color = mergeColors(color, secondHit, factor: factor)
            }
            
            // TODO: Improve handling of shadow and direct light in refractive materials
            
            // Shadow or sunlight
            let shadow = calculateShadow(for: hit)
            if shadow > 0 {
                // Shadow
                color = mergeColors(color, .black, factor: 0.5 * shadow)
            } else {
                // Sunlight direction
                let sunDirDot = max(0.0, min(1, pow(hit.normal.dot(-scene.sunDirection), 5)))
                
                if material.hasRefraction {
                    color = mergeColors(color, .white, factor: sunDirDot * refl)
                } else {
                    color = mergeColors(color, .white, factor: sunDirDot)
                }
            }
            
        case let .checkerboard(checkerSize, color1, color2):
            minimumShade = 0.6
            
            let checkerPhase = abs(hit.point) % checkerSize * 2
            
            var isColor1 = false
            
            switch (checkerPhase.x, checkerPhase.y) {
            case (checkerSize..., checkerSize...), (0...checkerSize, 0...checkerSize):
                isColor1 = false
            default:
                isColor1 = true
            }
            
            if hit.point.x < 0 {
                isColor1.toggle()
            }
            if hit.point.y < 0 {
                isColor1.toggle()
            }
            
            color = isColor1 ? color1 : color2
            
            // Shading
            let shade = max(0.0, min(1 - minimumShade, hit.normal.dot(-ray.direction)))
            color = mergeColors(color, .black, factor: 1 - shade)
            
        case let .target(center, stripeFrequency, color1, color2):
            let dist = hit.point.distance(to: center)
            
            let phase = dist.truncatingRemainder(dividingBy: stripeFrequency)
            if phase < stripeFrequency / 2 {
                color = color1
            } else {
                color = color2
            }
            
            // Shading
            let shade = max(0.0, min(1 - minimumShade, hit.normal.dot(-ray.direction)))
            color = mergeColors(color, .black, factor: 1 - shade)
        }
        
        // Fade distant pixels to skyColor
        let far = 1000.0
        let dist = ray.a.distanceSquared(to: hit.point)
        let distFactor = max(0, min(1, dist / (far * far)))
        color = mergeColors(color, scene.skyColor, factor: distFactor)
        
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
        let ray = RRay3D(start: hit.point, direction: -scene.sunDirection)
        
        let intersections = scene.intersectAll(ray: ray, ignoring: .full(id: hit.id))
        
        let transparency =
        intersections
            .map { scene.geometries[$0.id].material.transparency }
            .reduce(1.0, *)
        
        return max(0.0, min(1.0, 1 - transparency))
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
