import SwiftBlend2D
import ImagineUI
#if canImport(Geometria)
import Geometria
#endif

private var _attemptedDebugInMultithreadedYet = false

/// Class that performs raymarching on a scene.
public final class Raymarcher<Scene: RaymarchingSceneType>: RendererType {
    private var processingPrinter: RaytracerProcessingPrinter?
    private var materialMapCache: MaterialMap
    private var globalMarchParameters: MarchingParameters
    private var isDebugOn: Bool = false
    
    public var isMultiThreaded: Bool = false
    
    public let scene: Scene
    public let camera: Camera
    public var viewportSize: ViewportSize = .zero

    public var renderMode: RenderMode = .fullRender
    
    public init(scene: Scene, camera: Camera) {
        self.scene = scene
        self.camera = camera
        self.materialMapCache = scene.materialMap()

        self.globalMarchParameters = 
            MarchingParameters(
                maxMarchIterationCount: 250,
                minimumMarchTolerance: 0.01,
                maxDistance: 1000
            )
    }

    public func setupViewportSize(_ viewportSize: ViewportSize) {
        self.viewportSize = viewportSize
    }

    /// Gets the scene configured on this renderer.
    public func currentScene() -> SceneType {
        return scene
    }
    
    // MARK: - Debugging
    
    public func beginDebug() {
        if isMultiThreaded {
            if !_attemptedDebugInMultithreadedYet {
                _attemptedDebugInMultithreadedYet = true
                GeometriaLogger.warning("Attempted to invoke Raymarcher.beginDebug() with a multi-pixel, multi-threaded render, which is potentially not intended. Ignoring...")
            }
            
            return
        }

        isDebugOn = true

        processingPrinter =
            RaytracerProcessingPrinter(
                viewportSize: RVector2D(viewportSize),
                scene: currentScene(),
                sceneCamera: camera
            )
    }
    
    public func endDebug(target: ProcessingPrinterTarget?) {
        isDebugOn = false
        
        processingPrinter?.printAll(target: target)
        processingPrinter = nil
    }
    
    // MARK: - Ray Marching
    
    /// Does raymarching for a single pixel, returning the resulting color.
    public func render(pixelAt coord: PixelCoord) -> BLRgba32 {
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
        
        let maxMarchIterationCount = globalMarchParameters.maxMarchIterationCount
        let minimumMarchTolerance = globalMarchParameters.minimumMarchTolerance
        let maxDistance = globalMarchParameters.maxDistance

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
            if traveled >= maxDistance {
                escaped = true
                break
            }
            
            ray.start = ray.projectedMagnitude(signedDistance)
        }

        switch renderMode {
        case .marchSteps(let range):
            return computeRenderStepsColor(iterations: iteration, range: range)

        case .fullRender:
            break
        }

        if escaped {
            return scene.skyColor
        }
        
        let materialColor = result.material.map { computeColor(at: ray.start, materialId: $0) }
        var resultColor = materialColor ?? scene.skyColor

        // Compute color based on normal
        if hit, let materialColor = materialColor {
            let norm = calcNormal(ray.start)

            assert(!norm.x.isNaN && !norm.y.isNaN && !norm.z.isNaN, "!norm.x.isNaN && !norm.y.isNaN && !norm.z.isNaN")

            // TODO: Reflections?
            //let reflected = reflect(direction: ray.direction, normal: norm)

            // TODO: Transparency?
            //let invTransparency = 1.0
            //resultColor = mergeColors(scene.skyColor, materialColor, factor: invTransparency)

            resultColor = materialColor
            
            // Shading
            let minimumShade: Double = 0.0
            let shade = max(0.0, min(1 - minimumShade, norm.dot(-ray.direction)))
            resultColor = mergeColors(resultColor, .black, factor: 1 - shade)
        }

        // Compute shadow
        let shadowFactor = computeShadowFactor(at: ray.start, startDist: result.distance)
        resultColor = mergeColors(resultColor, .black, factor: (1 - shadowFactor) * 0.7)

        // Fade distant pixels to skyColor
        let far = maxDistance
        let dist = traveled
        let distFactor = max(0, min(1, dist / far))
        resultColor = mergeColors(resultColor, scene.skyColor, factor: distFactor * distFactor)
        
        return resultColor
    }

    private func computeRenderStepsColor(iterations: Int, range: [(steps: Int, color: BLRgba32)]) -> BLRgba32 {
        if isDebugOn {
            GeometriaLogger.info("Iterations: \(iterations)")
        }

        var range = range
        if range.isEmpty {
            range = [
                (steps: 0, color: BLRgba32.blue),
                (steps: globalMarchParameters.maxMarchIterationCount / 8, color: BLRgba32.green),
                (steps: globalMarchParameters.maxMarchIterationCount / 4, color: BLRgba32.yellow),
                (steps: globalMarchParameters.maxMarchIterationCount, color: BLRgba32.red),
            ]
        }

        range.sort { $0.steps < $1.steps }

        if isDebugOn {
            GeometriaLogger.info("Ranges: \(range)")
        }

        guard let startIndex = range.lastIndex(where: { $0.steps < iterations }), startIndex < range.count - 1 else {
            return range.last!.color
        }

        if isDebugOn {
            GeometriaLogger.info("Range index: \(startIndex)")
        }

        let current = range[startIndex]
        let next = range[startIndex + 1]
        
        let ratio = (Float(iterations) - Float(current.steps)) / (Float(next.steps) - Float(current.steps))
        let clamped = clamp(ratio, min: 0.0, max: 1.0)
        let color = current.color.faded(towards: next.color, factor: ratio)
        
        if isDebugOn {
            GeometriaLogger.info("Colors: \(current.color) - \(next.color)")
            GeometriaLogger.info("Color factor: \(ratio) (before clamp: \(clamped))")
            GeometriaLogger.info("Color: \(color)")
        }

        return color
    }

    private func computeShadowFactor(at point: RVector3D, startDist: Double, softShadowSizeFactor: Double = 8.0) -> Double {
        var ray = RRay3D(start: point - scene.sunDirection * startDist, direction: -scene.sunDirection)
        
        let maxMarchIterationCount = globalMarchParameters.maxMarchIterationCount
        let minimumMarchTolerance = min(globalMarchParameters.minimumMarchTolerance, startDist)
        let maxDistance = globalMarchParameters.maxDistance

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
            let d = (signedDistance * signedDistance - y * y).squareRoot()
            res = min(res, softShadowSizeFactor * d / max(0.0, traveled - y))
            ph = signedDistance
            traveled += signedDistance

            if traveled >= maxDistance {
                break
            }
            
            ray.start = ray.projectedMagnitude(signedDistance)
        }

        return max(0.0, min(1.0, res))
    }

    private func computeColor(at point: RVector3D, materialId: MaterialId) -> BLRgba32 {
        let material = materialMapCache[materialId]
        /*
        guard let material = materialMapCache[materialId] else {
            return .transparentBlack
        }
        */

        switch material {
        case .diffuse(let material):
            return material.color

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
        let signedDistance = 0.001 // TODO: Consider replacing by an appropriate value later
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

    /// Global parameters used for all raymarching operations.
    private struct MarchingParameters {
        /// Maximum number of raymarching steps to perform.
        var maxMarchIterationCount: Int

        /// The minimum marching distance before a hit is considered.
        var minimumMarchTolerance: Double

        /// The maximum global (world) coordinates to march.
        var maxDistance: Double
    }

    /// Specifies the rendering mode of a `Raymarcher` instance.
    public enum RenderMode {
        /// Does a fully colored, textured render.
        case fullRender

        /// Renders each pixel as the number of raymarching steps that it took
        /// to reach a geometry on the scene.
        ///
        /// The associated value `range` specifies the colors and the number of
        /// steps associated with each color. Colors are interpolated between
        /// each step count.
        /// If empty, a raymarcher instance may choose its own choice of default
        /// colors instead.
        case marchSteps(range: [(steps: Int, color: BLRgba32)] = [])
    }
}
