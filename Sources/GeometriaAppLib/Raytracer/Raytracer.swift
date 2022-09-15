import SwiftBlend2D
import ImagineUI
#if canImport(Geometria)
import Geometria
#endif

private var _attemptedDebugInMultithreadedYet = false

/// Class that performs raytracing on a scene.
final class Raytracer<Scene: RaytracingSceneType>: RendererType {
    private var processingPrinter: RaytracerProcessingPrinter?
    private var materialMapCache: MaterialMap
    
    private let minimumRayToleranceSq: Double = 0.00001
    
    /// Bias used when creating rays for refraction and reflection.
    private let bias: Double = 0.0001
    
    var isMultiThreaded: Bool = false
    var maxBounces: Int = 15
    let scene: Scene
    let camera: Camera
    var viewportSize: ViewportSize = .zero
    
    init(scene: Scene, camera: Camera) {
        self.scene = scene
        self.camera = camera
        self.materialMapCache = scene.materialMap()
    }

    func setupViewportSize(_ viewportSize: ViewportSize) {
        self.viewportSize = viewportSize
    }

    /// Gets the scene configured on this renderer.
    func currentScene() -> SceneType {
        return scene
    }
    
    // MARK: - Debugging
    
    func beginDebug() {
        if isMultiThreaded {
            if !_attemptedDebugInMultithreadedYet {
                _attemptedDebugInMultithreadedYet = true
                GeometriaLogger.warning("Attempted to invoke Raytracer.beginDebug() with a multi-pixel, multi-threaded render, which is potentially not intended. Ignoring...")
            }
            
            return
        }
        
        processingPrinter =
        RaytracerProcessingPrinter(
            viewportSize: RVector2D(viewportSize),
            scene: currentScene(),
            sceneCamera: camera
        )
    }
    
    func endDebug(target: ProcessingPrinterTarget?) {
        processingPrinter?.printAll(target: target)
        processingPrinter = nil
    }
    
    // MARK: - Ray Casting
    
    /// Perform raycasting for a single pixel, returning the resulting color.
    func render(pixelAt coord: PixelCoord) -> BLRgba32 {
        assert(coord >= .zero && coord < viewportSize, "\(coord) is not within \(PixelCoord.zero) x \(viewportSize) limits")
        
        let ray = camera.rayFromCamera(at: coord)
        
        processingPrinter?.add(ray: ray, comment: "Raycast @ pixel (x: \(coord.x), y: \(coord.y))")

        return raytrace(ray: ray).color
    }
    
    private func raytrace(ray: RRay3D, ignoring: RayIgnore = .none, bounceCount: Int = 0) -> RaytraceResult {
        if bounceCount > maxBounces {
            return RaytraceResult(color: BLRgba32.transparentBlack, dotSunDirection: 0.0)
        }
        
        guard let hit = scene.intersect(ray: ray, ignoring: ignoring) else {
            processingPrinter?.add(ray: ray)
            return RaytraceResult(color: scene.skyColor, dotSunDirection: 0.0)
        }
        
        processingPrinter?.addRaycast(hit: hit, ray: ray)
        
        // No material information, potentially a hit against invisible geometry?
        guard let material = hit.material else {
            return RaytraceResult(color: scene.skyColor, dotSunDirection: 0.0)
        }
        
        return computeColor(materialId: material, ray: ray, hit: hit, bounceCount: bounceCount)
    }
    
    private func computeColor(
        materialId: MaterialId,
        ray: RRay3D,
        hit: RayHit,
        ignoring: RayIgnore = .none,
        bounceCount: Int = 0
    ) -> RaytraceResult {
        
        let material = materialMapCache[materialId]
        
        // Detect short distances that should avoid re-bounces
        var canRebound = true
        switch ignoring {
        case .entrance(_, let minimumRayLengthSquared), .exit(_, let minimumRayLengthSquared):
            let dist = hit.point.distanceSquared(to: ray.start)
            if dist < minimumRayLengthSquared {
                canRebound = false
            }
            
        default:
            break
        }
        
        var color: BLRgba32
        var minimumShade: Double = 0.0
        var refl: Double = 1.0
        
        switch material {
        case .diffuse(let material):
            let invTransparency = 1 - material.transparency
            color = mergeColors(scene.skyColor, material.color, factor: invTransparency)
            
            // Shading
            let shade = max(0.0, min(1 - minimumShade, hit.normal.dot(-ray.direction)))
            color = mergeColors(color, .black, factor: (1 - shade) * invTransparency)
            
            // Find rates for reflection and transmission within material
            let trans: Double
            (refl, trans) = fresnel(ray.direction, hit.normal, material.refractiveIndex)
            
            // Transparency / refraction
            if material.transparency > 0.0 {
                // Raycast past geometry and add color
                var rayThroughObject: RRay3D = RRay3D(start: hit.point, direction: ray.direction)
                var rayIgnore: RayIgnore = hit.rayIgnoreForHit(minimumRayLengthSquared: minimumRayToleranceSq)
                
                // If refraction is active, create a ray that points to the exit
                // point of the refracted ray that was generated inside the object's
                // geometry.
            refraction:
                if trans > 0 && canRebound {
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
                    rayIgnore = .entrance(id: hit.id, minimumRayLengthSquared: minDistSq)
                    // Do a sanity check that the ray isn't going to collide
                    // immediately with the same geometry - if it does, skip the
                    // geometry fully in the subsequent raycast
                    let innerHit =
                        scene.intersect(
                            ray: innerRay, 
                            ignoring: .allButSingleId(id: hit.id, rayIgnore)
                        )

                    if let innerHit = innerHit, innerHit.point.distanceSquared(to: hit.point) <= minDistSq {
                        rayIgnore = .full(id: hit.id)
                    }
                    
                    rayThroughObject = innerRay
                }
                
                let backHit = raytrace(
                    ray: rayThroughObject,
                    ignoring: rayIgnore,
                    bounceCount: bounceCount + 1
                )

                color = mergeColors(color, backHit.color, factor: material.transparency * trans)
            }
            
            // Reflectivity
            if material.reflectivity > 0.0 && bounceCount < maxBounces && canRebound {
                // Raycast from normal and fade in the reflected color
                let ignoring: RayIgnore = hit.rayIgnoreForHit(minimumRayLengthSquared: minimumRayToleranceSq)
                
                let reflection = reflect(direction: ray.direction, normal: hit.normal)
                let normRay = RRay3D(start: hit.point, direction: reflection)
                
                processingPrinter?.add(ray: normRay, comment: "Reflection (direction: \(normRay.direction))")

                let secondHit = raytrace(
                    ray: normRay,
                    ignoring: ignoring,
                    bounceCount: bounceCount + 1
                )
                
                var factor: Double
                if material.refractiveIndex != 1.0 {
                    factor = refl + (1 - material.transparency)
                } else {
                    factor = refl + material.reflectivity
                }
                
                factor = max(0, min(1, factor))
                
                color = mergeColors(color, secondHit.color, factor: factor)
            }

            // TODO: Figure out how to handle refraction in shadow computation
            // TODO: bellow more gracefully.
            if !material.hasRefraction {
                refl = 1.0
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
        
        // TODO: Improve handling of shadow and direct light in refractive materials
        
        // Shadow or sunlight
        let normalSunDirection: Double
        let shadow = calculateShadow(for: hit)
        if shadow > 0 {
            // Shadow
            color = mergeColors(color, .black, factor: 0.5 * shadow)
            normalSunDirection = 0.0
        } else {
            // Sunlight direction
            normalSunDirection = hit.normal.dot(-scene.sunDirection)
            let sunDirDot = max(0.0, min(1, pow(normalSunDirection, 5)))
            
            color = mergeColors(color, .white, factor: sunDirDot * refl)
        }
        
        // Fade distant pixels to skyColor
        let far = 1000.0
        let dist = ray.a.distanceSquared(to: hit.point)
        let distFactor = max(0, min(1, dist / (far * far)))
        color = mergeColors(color, scene.skyColor, factor: distFactor)
        
        return RaytraceResult(color: color, dotSunDirection: normalSunDirection)
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
        if hit.normal.dot(-scene.sunDirection) < 0, let hitMaterial = hit.material {
            let material = materialMapCache[hitMaterial]
            
            if material.transparency == 0.0 {
                return 1.0
            }
        }
        
        let ray = RRay3D(start: hit.point, direction: -scene.sunDirection)
        
        processingPrinter?.addRaycast(ray: ray)
        
        var transparency: Double = 1.0

        let intersections = scene.intersectAll(
            ray: ray,
            ignoring: hit.rayIgnoreForHit(minimumRayLengthSquared: minimumRayToleranceSq)
        )
        
        for intersection in intersections {
            if intersection.id == hit.id && intersection.point.distanceSquared(to: hit.point) < 1 {
                continue
            }

            guard let material = intersection.material else {
                continue
            }
            
            processingPrinter?.add(hit: intersection)
            
            transparency *= materialMapCache[material].transparency
        }
        
        return max(0.0, min(1.0, 1 - transparency))
    }

    private struct RaytraceResult {
        var color: BLRgba32
        var dotSunDirection: Double

        func merge(_ other: Self) -> Self {
            other
        }
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
    
    // Compute sint using Snell's law
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
