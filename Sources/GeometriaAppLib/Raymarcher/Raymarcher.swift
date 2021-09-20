import SwiftBlend2D

/// Class that performs raymarching on a scene.
class Raymarcher {
    private static var _attemptedDebugInMultithreadedYet = false
    private var processingPrinter: RaytracerProcessingPrinter?
    
    private let minimumMarchToleranceSq: Double = 0.001
    
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
            if !Raymarcher._attemptedDebugInMultithreadedYet {
                Raymarcher._attemptedDebugInMultithreadedYet = true
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
    func raymarch(pixelAt coord: PixelCoord) -> BLRgba32 {
        assert(coord >= .zero && coord < viewportSize, "\(coord) is not within \(PixelCoord.zero) x \(viewportSize) limits")
        
        let ray = camera.rayFromCamera(at: coord)
        return raytrace(ray: ray)
    }
    
    private func raytrace(ray: RRay3D, ignoring: RayIgnore = .none, bounceCount: Int = 0) -> BLRgba32 {
        return scene.skyColor
    }
}
