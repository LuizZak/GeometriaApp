import SwiftBlend2D

/// Class that performs raymarching on a scene.
final class Raymarcher: RendererType {
    private static var _attemptedDebugInMultithreadedYet = false
    private var processingPrinter: RaytracerProcessingPrinter?
    
    var isMultiThreaded: Bool = false
    var maxBounces: Int = 5
    var scene: Scene
    var camera: Camera
    var viewportSize: PixelCoord
    
    init(scene: Scene, camera: Camera, viewportSize: PixelCoord) {
        self.scene = scene
        self.camera = camera
        self.viewportSize = viewportSize
    }
    
    // MARK: - Debugging
    
    func beginDebug() {
        if isMultiThreaded {
            if !Self._attemptedDebugInMultithreadedYet {
                Self._attemptedDebugInMultithreadedYet = true
                print("Attempted to invoke Raymarcher.beginDebug() with a multi-pixel, multi-threaded render, which is potentially not intended. Ignoring...")
            }
            
            return
        }
        
        processingPrinter =
        RaytracerProcessingPrinter(
            viewportSize: viewportSize,
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
    
    private func raymarch(ray: RRay3D, bounceCount: Int = 0) -> BLRgba32 {
        // Max ray march iteration count
        var ray = ray
        
        let maxMarchIterationCount = 50
        let minimumMarchTolerance: Double = 0.001
        var iteration = 0
        
        while iteration < maxMarchIterationCount {
            defer { iteration += 1 }
            
            let next = distanceFunction(ray.start)
            
            let signedDistance = next.signedDistance
            
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
            
            ray.start = ray.projectedMagnitude(signedDistance)
        }
        
        // Sketch a dummy pixel color value for now
        let factor: Double = Double(iteration) / Double(maxMarchIterationCount)
        
        return mergeColors(scene.skyColor, .black, factor: factor)
    }
    
    private func distanceFunction(_ vector: RVector3D) -> MarchResult {
        var dist: Double = .infinity
        
        for geo in scene.geometries {
            dist = min(dist, geo.signedDistanceFunction(vector, minDistance: dist))
        }
        
        return MarchResult(signedDistance: dist)
    }
    
    private struct MarchResult {
        /// Distance to nearest geometry
        var signedDistance: Double
    }
}
