import Foundation
import ImagineUI
import SwiftBlend2D

class RaytracerUI: ImagineUIContentType {
    private let ui: ImagineUIWindowContent
    private let dialogsContainer: View = View()
    private var components: [RaytracerUIComponent] = []

    /// Indicates a currently opened dialog.
    private var dialogState: DialogState?

    /// View that dialogs should be added as subviews to.
    private var dialogsTargetView: View {
        dialogsContainer
    }

    /// The root view container for the UI.
    private var rootContainer: RootView {
        return ui.rootView
    }

    /// The view all components are added to.
    let componentsContainer: View = View()

    var size: UIIntSize

    var preferredRenderScale: UIVector {
        ui.preferredRenderScale
    }

    weak var delegate: ImagineUIContentDelegate? {
        get {
            ui.delegate
        }
        set {
            ui.delegate = newValue
        }
    }

    /// Gets or sets the debug draw flags.
    ///
    /// Changing this value invalidates the screen.
    var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> {
        get {
           ui.debugDrawFlags
        }
        set {
           ui.debugDrawFlags = newValue
        }
    }

    init(uiWrapper: ImagineUIWindowContent) {
        self.size = uiWrapper.size
        self.ui = uiWrapper

        initialize()
    }

    private func initialize() {
        ui.rootView.addSubview(componentsContainer)

        componentsContainer.layout.makeConstraints { make in
            make.edges == ui.rootView
        }
    }

    func addComponent(_ component: RaytracerUIComponent) {
        _addComponent(component, container: componentsContainer)
    }

    func addComponentInReservedView(_ component: RaytracerUIComponent) -> View {
        let container = View()
        componentsContainer.addSubview(container)

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

    func didCloseWindow() {
        ui.didCloseWindow()
    }
    
    func willStartLiveResize() {
        ui.willStartLiveResize()
    }

    func didEndLiveResize() {
        ui.didEndLiveResize()
    }

    func resize(_ size: UIIntSize) {
        ui.resize(size)
    }
    
    func performLayout() {
        ui.performLayout()
    }

    func update(_ time: TimeInterval) {
        ui.update(time)
    }

    func render(renderer: Renderer, renderScale: UIVector, clipRegion: ClipRegionType) {
        ui.render(renderer: renderer, renderScale: renderScale, clipRegion: clipRegion)
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

    func keyPress(event: KeyPressEventArgs) {
        ui.keyPress(event: event)
    }

    private func _setupDialogsContainer() {
        ui.rootView.addSubview(dialogsContainer)
        
        dialogsContainer.layout.makeConstraints { make in
            make.edges == ui.rootView
        }
    }

    private func _teardownDialogsContainer() {
        dialogsContainer.removeFromSuperview()
    }

    private func _openDialog(_ dialog: UIDialog, location: UIDialogInitialLocation) -> Bool {
        if dialogState != nil {
            return false
        }

        _setupDialogsContainer()

        let background: View
        if let suggestedBackground = dialog.customBackdrop() {
            background = suggestedBackground
        } else {
            let bg = ControlView()
            bg.backColor = .black.withTransparency(20)
            background = bg
        }

        let shadowRadius: Double = 8.0
        let dropShadowView = DropShadowView(shadowRadius: shadowRadius)

        let state = DialogState(dialog: dialog, background: background, dropShadowView: dropShadowView)

        dialogState = state

        dialogsTargetView.addSubview(background)
        dialogsTargetView.addSubview(dropShadowView)
        dialogsTargetView.addSubview(dialog)

        background.layout.makeConstraints { make in
            make.edges == dialogsTargetView
        }

        dropShadowView.layout.makeConstraints { make in
            make.edges.equalTo(dialog, inset: -UIEdgeInsets(shadowRadius))
        }

        switch location {
        case .unspecified:
            break
        
        case .topLeft(let location, nil):
            dialog.location = location

        case .topLeft(let location, let reference?):
            dialog.location = reference.convert(point: location, to: nil)

        case .centered:
            // Refresh layout to acquire the proper view size
            dialog.performLayout()

            dialog.location = (dialogsTargetView.size / 2 - dialog.size / 2).asUIPoint
        }

        dialog.dialogDelegate = self

        dialog.didOpen()

        return true
    }

    private func _removeDialog() {
        guard let state = dialogState else { return }

        _teardownDialogsContainer()

        state.background.removeFromSuperview()
        state.dropShadowView.removeFromSuperview()
        state.dialog.removeFromSuperview()

        dialogState = nil

        state.dialog.didClose()
    }

    /// Wraps the state of a displayed dialog.
    private struct DialogState {
        /// The dialog window currently opened.
        var dialog: UIDialog

        /// Background that obscures the underlying views
        var background: View

        /// View that renders the drop shadow for the dialog view.
        var dropShadowView: View
    }

    private class DropShadowView: View {
        var shadowColor: Color = .black {
            didSet {
                invalidate()
            }
        }

        var shadowRadius: Double {
            didSet {
                invalidate()
            }
        }

        /// Value between 0 - 1 that indicates how dark the shadow will be.
        /// Values of 0 render no shadow, 1 renders a fully opaque black box
        /// that graduates into a transparent color towards the corners of the
        /// view's bounds according to the shadow radius.
        var shadowFactor: Double = 0.3 {
            didSet {
                invalidate()
            }
        }

        private var effectiveShadowColor: Color {
            shadowColor.withTransparency(Int(255 * shadowFactor))
        }

        init(shadowRadius: Double) {
            self.shadowRadius = shadowRadius

            super.init()
        }

        override func render(in renderer: Renderer, screenRegion: ClipRegionType) {
            renderer.withTemporaryState {
                renderer.setFill(effectiveShadowColor)
                renderer.fill(bounds.insetBy(x: shadowRadius * 2, y: shadowRadius * 2))

                _drawCornerGradient(renderer: renderer, corner: .topLeft, radius: shadowRadius)
                _drawCornerGradient(renderer: renderer, corner: .topRight, radius: shadowRadius)
                _drawCornerGradient(renderer: renderer, corner: .bottomRight, radius: shadowRadius)
                _drawCornerGradient(renderer: renderer, corner: .bottomLeft, radius: shadowRadius)

                _drawSideGradient(renderer: renderer, side: .left, length: shadowRadius)
                _drawSideGradient(renderer: renderer, side: .top, length: shadowRadius)
                _drawSideGradient(renderer: renderer, side: .right, length: shadowRadius)
                _drawSideGradient(renderer: renderer, side: .bottom, length: shadowRadius)
            }
        }

        private func _gradientStops() -> [Gradient.Stop] {
            let baseColor = effectiveShadowColor

            return [
                .init(offset: 0, color: baseColor),
                .init(offset: 1, color: baseColor.withTransparency(0))
            ]
        }

        private func _drawCornerGradient(renderer: Renderer, corner: GradientCorner, radius: Double) {
            let radiusVector = UIVector(repeating: radius)
            var gradientCircle = UICircle(center: .zero, radius: radius)
            let arcStart: Double
            let arcSweep: Double = .pi / 2

            switch corner {
            case .topLeft:
                gradientCircle.center = bounds.topLeft + radiusVector
                arcStart = .pi
                
            case .topRight:
                gradientCircle.center = bounds.topRight + radiusVector * UIVector(x: -1, y: 1)
                arcStart = -.pi / 2

            case .bottomRight:
                gradientCircle.center = bounds.bottomRight - radiusVector
                arcStart = 0

            case .bottomLeft:
                gradientCircle.center = bounds.bottomLeft + radiusVector * UIVector(x: 1, y: -1)
                arcStart = .pi / 2
            }

            let pie = gradientCircle.arc(start: arcStart, sweep: arcSweep)

            let gradient = Gradient.radial(
                center: gradientCircle.center,
                radius: radius,
                stops: _gradientStops()
            )

            renderer.withTemporaryState {
                renderer.setFill(gradient)
                renderer.fill(pie: pie)
            }
        }

        private func _drawSideGradient(renderer: Renderer, side: GradientSide, length: Double) {
            let start: UIVector
            let end: UIVector
            var gradientBounds: UIRectangle

            switch side {
            case .left:
                start = bounds.topLeft + UIVector(x: length, y: 0)
                end = bounds.topLeft
                gradientBounds =
                    UIRectangle(
                        location: bounds.topLeft + UIVector(x: 0, y: length),
                        size: UISize(width: length, height: bounds.height - length * 2)
                    )

            case .top:
                start = bounds.topLeft + UIVector(x: 0, y: length)
                end = bounds.topLeft
                gradientBounds =
                    UIRectangle(
                        location: bounds.topLeft + UIVector(x: length, y: 0),
                        size: UISize(width: bounds.width - length * 2, height: length)
                    )

            case .right:
                start = bounds.topRight - UIVector(x: length, y: 0)
                end = bounds.topRight
                gradientBounds =
                    UIRectangle(
                        location: bounds.topRight - UIPoint(x: length, y: -length),
                        size: UISize(width: length, height: bounds.height - length * 2)
                    )

            case .bottom:
                start = bounds.bottomLeft - UIVector(x: 0, y: length)
                end = bounds.bottomLeft
                gradientBounds =
                    UIRectangle(
                        location: bounds.bottomLeft - UIPoint(x: -length, y: length),
                        size: UISize(width: bounds.width - length * 2, height: length)
                    )
            }

            let gradient = Gradient.linear(
                start: start,
                end: end,
                stops: _gradientStops()
            )

            renderer.withTemporaryState {
                renderer.setFill(gradient)
                renderer.fill(gradientBounds)
            }
        }

        private enum GradientCorner {
            case topLeft
            case topRight
            case bottomRight
            case bottomLeft
        }

        private enum GradientSide {
            case left
            case top
            case right
            case bottom
        }
    }
}

extension RaytracerUI: RaytracerUIComponentDelegate {
    func openDialog(_ view: UIDialog, location: UIDialogInitialLocation) -> Bool {
        return _openDialog(view, location: location)
    }
}

extension RaytracerUI: UIDialogDelegate {
    func dialogWantsToClose(_ dialog: UIDialog) {
        guard dialog === dialogState?.dialog else { return }

        _removeDialog()
    }
}
