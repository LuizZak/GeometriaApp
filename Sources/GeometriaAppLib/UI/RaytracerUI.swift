import Foundation
import ImagineUI
import SwiftBlend2D

/// Base class for GeometriaApp UI windows.
open class RaytracerUI: ImagineUIWindowContent {
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
        return rootView
    }

    /// The view all components are added to.
    public let componentsContainer: View = View()

    override public init(size: UIIntSize) {
        super.init(size: size)
    }

    open override func initialize() {
        super.initialize()

        rootView.addSubview(componentsContainer)

        componentsContainer.layout.makeConstraints { make in
            make.edges == rootView
        }
    }

    public func addComponent(_ component: RaytracerUIComponent) {
        _addComponent(component, container: componentsContainer)
    }

    public func addComponentInReservedView(_ component: RaytracerUIComponent) -> View {
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
    
    open func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {
        for component in components {
            component.rendererCoordinatorChanged(coordinator)
        }
    }
    
    open func rendererChanged<T: RendererType>(anyRenderer: T) {
        for component in components {
            component.rendererChanged(anyRenderer: anyRenderer)
        }
    }

    open func rendererChanged<T>(_ renderer: Raytracer<T>) {
        for component in components {
            component.rendererChanged(renderer)
        }
    }

    open func rendererChanged<T>(_ renderer: Raymarcher<T>) {
        for component in components {
            component.rendererChanged(renderer)
        }
    }

    // MARK: Event forwarding

    open override func mouseMoved(event: MouseEventArgs) {
        super.mouseMoved(event: event)

        for component in components {
            component.mouseMoved(event: event)
        }
    }

    private func _setupDialogsContainer() {
        rootView.addSubview(dialogsContainer)
        
        dialogsContainer.layout.makeConstraints { make in
            make.edges == rootView
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

    private func _showTooltip(
        _ provider: TooltipProvider,
        location: PreferredTooltipLocation? = nil
    ) {
        
        controlSystem.showTooltip(for: provider, location: location)
    }

    private func _hideTooltips() {
        controlSystem.hideTooltip(stopTimers: true)
    }

    private func _beginCustomTooltipLifetime() -> CustomTooltipHandlerType? {
        controlSystem.beginCustomTooltipLifetime()
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
    public func openDialog(_ view: UIDialog, location: UIDialogInitialLocation) -> Bool {
        return _openDialog(view, location: location)
    }

    public func beginCustomTooltipLifetime() -> CustomTooltipHandlerType? {
        _beginCustomTooltipLifetime()
    }
}

extension RaytracerUI: UIDialogDelegate {
    public func dialogWantsToClose(_ dialog: UIDialog) {
        guard dialog === dialogState?.dialog else { return }

        _removeDialog()
    }
}
