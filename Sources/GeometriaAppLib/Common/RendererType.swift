import SwiftBlend2D

protocol RendererType: AnyObject {
    /// Gets or sets the camera for this renderer.
    ///
    /// Should not be set on multi-threaded contexts with potential for data
    /// races.
    var camera: Camera { get set }
    
    /// Gets or sets whether this renderer is running in a multi-threaded context.
    ///
    /// Should not be set on multi-threaded contexts with potential for data
    /// races.
    var isMultiThreaded: Bool { get set }
    
    /// Requests rendering for a pixel at a given coordinate.
    ///
    /// It is safe to call in multi-threaded contexts.
    func render(pixelAt coord: PixelCoord) -> BLRgba32
    
    func beginDebug()
    func endDebug()
}
