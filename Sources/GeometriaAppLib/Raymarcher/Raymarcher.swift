import SwiftBlend2D
import ImagineUI

private var _attemptedDebugInMultithreadedYet = false

/// Class that performs raymarching on a scene.
final class Raymarcher<SceneType: RaymarchingSceneType>: RendererType {
    private var processingPrinter: RaytracerProcessingPrinter?
    
    let scene: SceneType
    let camera: Camera
    let viewportSize: ViewportSize
    var isMultiThreaded: Bool = false
    
    init(scene: SceneType, camera: Camera, viewportSize: ViewportSize) {
        self.scene = scene
        self.camera = camera
        self.viewportSize = viewportSize
    }
    
    // MARK: - Debugging
    
    func beginDebug() {
        if isMultiThreaded {
            if !_attemptedDebugInMultithreadedYet {
                _attemptedDebugInMultithreadedYet = true
                print("Attempted to invoke Raymarcher.beginDebug() with a multi-pixel, multi-threaded render, which is potentially not intended. Ignoring...")
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
    
    // MARK: - Ray Marching
    
    /// Does raymarching for a single pixel, returning the resulting color.
    func render(pixelAt coord: PixelCoord) -> BLRgba32 {
        assert(coord >= .zero && coord < viewportSize, "\(coord) is not within \(PixelCoord.zero) x \(viewportSize) limits")
        
        let ray = camera.rayFromCamera(at: coord)
        return raymarch(ray: ray)
    }
    
    /// Performs the distance function for a given point
    private func distanceFunction(_ vector: RVector3D) -> RaymarchingResult {
        scene.signedDistance(to: vector, current: .emptyResult())
    }

    private func raymarch(ray: RRay3D, bounceCount: Int = 0) -> BLRgba32 {
        var ray = ray
        
        let maxMarchIterationCount = 500
        let minimumMarchTolerance: Double = 0.001
        let maxDistance: Double = 10000

        var result: RaymarchingResult = .emptyResult()
        var traveled: Double = 0.0
        var iteration = 0
        var hit = false
        var escaped = false
        
        while iteration < maxMarchIterationCount {
            defer { iteration += 1 }
            
            result = distanceFunction(ray.start)
            
            let signedDistance = result.distance
            traveled += signedDistance
            
            // Scene is empty?
            if signedDistance.isInfinite {
                escaped = true
                break
            }
            // Something broke in the algorithms?
            if signedDistance.isNaN {
                break
            }
            
            if signedDistance < minimumMarchTolerance {
                hit = true
                break
            }
            if signedDistance >= maxDistance {
                escaped = true
                break
            }
            
            ray.start = ray.projectedMagnitude(signedDistance)
        }

        escaped = escaped || iteration == maxMarchIterationCount

        let materialColor = result.material.map { computeColor(at: ray.start, material: $0) }

        var resultColor: BLRgba32
        if escaped {
            resultColor = scene.skyColor
        } else {
            resultColor = materialColor ?? scene.skyColor
        }
        
        // Compute color based on normal
        if hit, let materialColor = materialColor {
            let norm = calcNormal(ray.start)

            // TODO: Reflections?
            //let reflected = reflect(direction: ray.direction, normal: norm)
            
            // Shading
            let invTransparency = 1.0
            let minimumShade: Double = 0.0

            resultColor = mergeColors(scene.skyColor, materialColor, factor: invTransparency)
            
            let shade = max(0.0, min(1 - minimumShade, norm.dot(-ray.direction)))
            resultColor = mergeColors(resultColor, .black, factor: (1 - shade) * invTransparency)
        }

        // Compute shadow
        let shadowFactor = computeShadowFactor(at: ray.start, startDist: result.distance)
        resultColor = mergeColors(resultColor, .black, factor: (1 - shadowFactor) * 0.7)

        return resultColor
    }

    private func computeShadowFactor(at point: RVector3D, startDist: Double, softShadowSizeFactor: Double = 8.0) -> Double {
        var ray = RRay3D(start: point - scene.sunDirection * startDist, direction: -scene.sunDirection)
        
        let maxMarchIterationCount = 500
        let minimumMarchTolerance: Double = min(startDist, 0.001)
        let maxDistance: Double = 10000

        var result: RaymarchingResult = .emptyResult()
        var iteration = 0
        var traveled = startDist
        var res = 1.0
        var ph: Double = 1e20
        
        while iteration < maxMarchIterationCount {
            defer { iteration += 1 }
            
            result = distanceFunction(ray.start)

            let signedDistance = result.distance

            // Scene is empty?
            if signedDistance.isInfinite {
                return 1.0
            }
            // Something broke in the algorithms?
            if signedDistance.isNaN {
                break
            }
            
            if signedDistance < minimumMarchTolerance {
                return 0.0
            }

            let y = signedDistance * signedDistance / (2.0 * ph)
            let d = sqrt(signedDistance * signedDistance - y * y)
            res = min(res, softShadowSizeFactor * d / max(0.0, traveled - y))
            ph = signedDistance
            traveled += signedDistance

            if signedDistance >= maxDistance {
                break
            }
            
            ray.start = ray.projectedMagnitude(signedDistance)
        }

        return res
    }

    private func computeColor(at point: RVector3D, material: RaymarcherMaterial) -> BLRgba32 {
        switch material {
        case .solid(let color):
            return color

        case let .checkerboard(checkerSize, color1, color2):
            let checkerPhase = abs(point) % checkerSize * 2
            
            var isColor1 = false
            
            switch (checkerPhase.x, checkerPhase.y) {
            case (checkerSize..., checkerSize...), (0...checkerSize, 0...checkerSize):
                isColor1 = false
            default:
                isColor1 = true
            }
            
            if point.x < 0 {
                isColor1.toggle()
            }
            if point.y < 0 {
                isColor1.toggle()
            }
            
            return isColor1 ? color1 : color2

        case let .target(center, freq, c1, c2):
            let dist = point.distance(to: center)
            
            let phase = dist.truncatingRemainder(dividingBy: freq)

            if phase < freq / 2 {
                return c1
            }

            return c2
        }
    }

    // Normal derivation from: https://www.iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
    private func calcNormal(_ p: RVector3D) -> RVector3D {
        let signedDistance = 0.0001 // replace by an appropriate value
        let k = RVector2D(x: 1, y: -1)
        
        // Tetrahedron points
        let k_xyy = RVector3D(x: k.x, y: k.y, z: k.y) // k.xyy
        let k_yyx = RVector3D(x: k.y, y: k.y, z: k.x) // k.yyx
        let k_yxy = RVector3D(x: k.y, y: k.x, z: k.y) // k.yxy
        let k_xxx = RVector3D(x: k.x, y: k.x, z: k.x) // k.xxx

        let df: (RVector3D) -> Double = { self.distanceFunction($0).distance }

        let n1 = k_xyy * df(p + k_xyy * signedDistance)
        let n2 = k_yyx * df(p + k_yyx * signedDistance)
        let n3 = k_yxy * df(p + k_yxy * signedDistance)
        let n4 = k_xxx * df(p + k_xxx * signedDistance)

        return (n1 + n2 + n3 + n4).normalized()
    }
    
    /// Reflects an incoming direction across a normal, returning a new direction
    /// such that the angle between `direction <- normal` is the same as
    /// `normal -> result`.
    private func reflect(direction: RVector3D, normal: RVector3D) -> RVector3D {
        // R = D - 2(D • N)N
        return direction - 2 * direction.dot(normal) * normal
    }
}
