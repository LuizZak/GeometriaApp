import Foundation
import ImagineUI
import Blend2DRenderer
import GeometriaAppLib

class ControlsComponent: RaytracerUIComponent {
    private let backdrop = ControlView()
    private let stackView = StackView(orientation: .horizontal)

    weak var delegate: (any RaytracerUIComponentDelegate)?
    weak var controlsDelegate: (any Delegate)?

    func setup(container: ImagineUICore.View) {
        container.addSubview(backdrop)
        backdrop.addSubview(stackView)

        backdrop.layout.makeConstraints { make in
            make.edges == container
            (make.height == 0) | .medium
            (make.height >= 32) | .high
        }
        stackView.layout.makeConstraints { make in
            (make.left, make.top) == backdrop
            make.bottom == backdrop
        }

        //
        backdrop.backColor = .dimGray
        backdrop.strokeColor = .darkGray
        backdrop.strokeWidth = 1

        stackView.alignment = .centered
        stackView.contentInset = .init(left: 5, top: 0, right: 5, bottom: 0)

        createControls()
    }

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) { }
    func rendererChanged<T>(anyRenderer: T) where T : GeometriaAppLib.RendererType { }

    func createControls() {
        func addButton(image: any Image, action: @escaping (ControlsComponent, Button) -> Void) {
            let button = Button(title: "")
            button.strokeColor = .transparentBlack
            button.strokeWidth = 0.0
            button.setBackgroundColor(.transparentWhite, forState: .normal)
            button.setBackgroundColor(.white.withTransparency(20), forState: .highlighted)
            button.setBackgroundColor(.black.withTransparency(20), forState: .selected)

            button.label.attributedText = "\(" ", attributes: [.image: ImageAttribute(image: image)])"

            stackView.addArrangedSubview(button)

            button.mouseClicked.addWeakListener(self) { (listener, event) in
                guard let button = event.sender as? Button else { return }

                action(listener, button)
            }
        }

        addButton(image: GraphBuilderIconLibrary.runIcon) { listener, button in
            listener.controlsDelegate?.controlsComponent(
                listener,
                didPressRenderButton: button
            )
        }
    }

    protocol Delegate: AnyObject {
        func controlsComponent(
            _ component: ControlsComponent,
            didPressRenderButton button: Button
        )
    }
}
