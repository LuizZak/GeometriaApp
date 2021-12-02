import Foundation
import ImagineUI
import SwiftBlend2D

class RaytracerUI {
    private let ui: ImagineUIWrapper
    private var components: [RaytracerUIComponent] = []

    weak var delegate: Blend2DAppDelegate? {
        didSet {
            ui.delegate = delegate
        }
    }

    init(uiWrapper: ImagineUIWrapper) {
        self.ui = uiWrapper
    }

    func addComponent(_ component: RaytracerUIComponent) {
        component.delegate = self
        component.setup(container: ui.rootView)

        components.append(component)
    }
    
    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {
        for component in components {
            component.rendererCoordinatorChanged(coordinator)
        }
    }
    
    func rendererChanged<T: RendererType>(anyRenderer: T) {
        for component in components {
            component.rendererChanged(anyRenderer: anyRenderer)
        }
    }

    func rendererChanged<T>(_ renderer: Raytracer<T>) {
        for component in components {
            component.rendererChanged(renderer)
        }
    }

    func rendererChanged<T>(_ renderer: Raymarcher<T>) {
        for component in components {
            component.rendererChanged(renderer)
        }
    }

    // MARK: Event forwarding
    
    func willStartLiveResize() {
        ui.willStartLiveResize()
    }

    func didEndLiveResize() {
        ui.didEndLiveResize()
    }

    func resize(width: Int, height: Int) {
        ui.resize(width: width, height: height)
    }
    
    func performLayout() {
        ui.performLayout()
    }

    func update(_ time: TimeInterval) {
        ui.update(time)
    }

    func render(context ctx: BLContext) {
        ui.render(context: ctx)
    }
    
    func mouseDown(event: MouseEventArgs) {
        ui.mouseDown(event: event)
    }

    func mouseMoved(event: MouseEventArgs) {
        ui.mouseMoved(event: event)

        for component in components {
            component.mouseMoved(event: event)
        }
    }

    func mouseUp(event: MouseEventArgs) {
        ui.mouseUp(event: event)
    }

    func mouseScroll(event: MouseEventArgs) {
        ui.mouseScroll(event: event)
    }
    
    func keyDown(event: KeyEventArgs) {
        ui.keyDown(event: event)
    }

    func keyUp(event: KeyEventArgs) {
        ui.keyUp(event: event)
    }
}

extension RaytracerUI: RaytracerUIComponentDelegate {

}
