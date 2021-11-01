import Foundation
import ImagineUI

protocol RaytracerUIComponent: AnyObject {
    var delegate: RaytracerUIComponentDelegate? { get set }

    func setup(container: View)

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?)
    func rendererChanged(_ renderer: RendererType)

    func mouseMoved(event: MouseEventArgs)
}

protocol RaytracerUIComponentDelegate: AnyObject {
    
}
