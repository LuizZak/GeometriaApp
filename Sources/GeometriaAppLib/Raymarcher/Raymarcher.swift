import SwiftBlend2D
import ImagineUI

private var _attemptedDebugInMultithreadedYet = false

/// Class that performs raymarching on a scene.
struct Raymarcher<SceneType: RaymarchingSceneType>: RendererType {
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
    
    mutating func beginDebug() {
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
    
    mutating func endDebug() {
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
    
    private func raymarch(ray: RRay3D, bounceCount: Int = 0) -> BLRgba32 {
        // Max ray march iteration count
        var ray = ray
        
        let maxMarchIterationCount = 50
        let minimumMarchTolerance: Double = 0.001
        let maxDistance: Double = 1000

        var iteration = 0
        
        while iteration < maxMarchIterationCount {
            defer { iteration += 1 }
            
            let next = distanceFunction(ray.start)
            
            let signedDistance = next.distance
            
            // Scene is empty?
            if signedDistance.isInfinite {
                break
            }
            // Something broke in the algorithms?
            if signedDistance.isNaN {
                break
            }
            
            if signedDistance < minimumMarchTolerance {
                break
            }
            if signedDistance >= maxDistance {
                iteration = maxMarchIterationCount
                break
            }
            
            ray.start = ray.projectedMagnitude(signedDistance)
        }
        
        // Sketch a dummy pixel color value for now
        let factor: Double = Double(iteration) / Double(maxMarchIterationCount)
        
        return mergeColors(scene.skyColor, .black, factor: 1 - factor)
    }
    
    private func distanceFunction(_ vector: RVector3D) -> RaymarchingResult {
        scene.signedDistance(to: vector, current: .emptyResult())
    }
}
