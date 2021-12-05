import Foundation
import ImagineUI
import SwiftBlend2D

class RaytracerUI {
    private let ui: ImagineUIWrapper
    private var components: [RaytracerUIComponent] = []

    /// Indicates a currently opened dialog.
    private var dialogState: DialogState?

    /// View that dialogs should be added as subviews to.
    private var dialogsTargetView: View {
        ui.rootView
    }

    /// The root view container for the UI.
    var rootContainer: RootView {
        return ui.rootView
    }

    weak var delegate: Blend2DAppDelegate? {
        didSet {
            ui.delegate = delegate
        }
    }

    init(uiWrapper: ImagineUIWrapper) {
        self.ui = uiWrapper
    }

    func addComponent(_ component: RaytracerUIComponent) {
        _addComponent(component, container: ui.rootView)
    }

    func addComponentInReservedView(_ component: RaytracerUIComponent) -> View {
        let container = View()
        ui.rootView.addSubview(container)

        _addComponent(component, container: container)

        return container
    }

    private func _addComponent(_ component: RaytracerUIComponent, container: View) {
        component.delegate = self
        component.setup(container: container)

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

    private func _openDialog(_ view: UIDialog, location: UIDialogInitialLocation) -> Bool {
        if dialogState != nil {
            return false
        }

        let background = ControlView()
        background.backColor = .black.withTransparency(20)

        let state = DialogState(dialog: view, background: background)

        dialogState = state

        dialogsTargetView.addSubview(background)
        dialogsTargetView.addSubview(view)

        background.layout.makeConstraints { make in
            make.edges == dialogsTargetView
        }

        switch location {
        case .unspecified:
            break
        
        case .topLeft(let location, nil):
            view.location = location

        case .topLeft(let location, let reference?):
            view.location = reference.convert(point: location, to: nil)

        case .centered:
            // Refresh layout to acquire the proper view size
            view.performLayout()

            view.location = (dialogsTargetView.size / 2 - view.size / 2).asUIPoint
        }

        return true
    }

    /// Wraps the state of a displayed dialog.
    private struct DialogState {
        /// The dialog window currently opened.
        var dialog: UIDialog

        /// Background that obscures the underlying views
        var background: ControlView
    }
}

extension RaytracerUI: RaytracerUIComponentDelegate {
    func openDialog(_ view: UIDialog, location: UIDialogInitialLocation) -> Bool {
        return _openDialog(view, location: location)
    }
}

extension RaytracerUI: UIDialogDelegate {
    func dialogClosed(_ dialog: UIDialog) {

    }
}
