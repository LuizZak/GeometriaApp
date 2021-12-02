import Foundation
import ImagineUI

protocol RaytracerUIComponent: AnyObject {
    var delegate: RaytracerUIComponentDelegate? { get set }

    func setup(container: View)

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?)
    func rendererChanged<T: RendererType>(anyRenderer: T)
    func rendererChanged<T>(_ renderer: Raytracer<T>)
    func rendererChanged<T>(_ renderer: Raymarcher<T>)

    func mouseMoved(event: MouseEventArgs)
}

extension RaytracerUIComponent {
    func rendererChanged<T>(_ renderer: Raytracer<T>) {
        rendererChanged(anyRenderer: renderer)
    }

    func rendererChanged<T>(_ renderer: Raymarcher<T>) {
        rendererChanged(anyRenderer: renderer)
    }
}

protocol RaytracerUIComponentDelegate: AnyObject {
    
}
