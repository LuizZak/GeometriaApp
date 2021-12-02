import Foundation
import ImagineUI

protocol RaytracerUIComponent: AnyObject {
    var delegate: RaytracerUIComponentDelegate? { get set }

    func setup(container: View)

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?)
    func rendererChanged(_ renderer: RendererType)
    func rendererChanged<T>(_ renderer: Raytracer<T>)
    func rendererChanged<T>(_ renderer: Raymarcher<T>)

    func mouseMoved(event: MouseEventArgs)
}

extension RaytracerUIComponent {
    func rendererChanged<T>(_ renderer: Raytracer<T>) {
        rendererChanged(renderer as RendererType)
    }

    func rendererChanged<T>(_ renderer: Raymarcher<T>) {
        rendererChanged(renderer as RendererType)
    }
}

protocol RaytracerUIComponentDelegate: AnyObject {
    
}
