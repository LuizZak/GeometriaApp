import Foundation
import ImagineUI
import Blend2DRenderer

class SceneGraphBuilderComponent: RaytracerUIComponent {
    private let _builderView: SceneGraphBuilderView = SceneGraphBuilderView()
    private let _controller: SceneGraphBuilderController = SceneGraphBuilderController()

    weak var delegate: RaytracerUIComponentDelegate?

    init() {
        _builderView.delegate = self

        _controller.uiDelegate = _builderView
        _controller.initialize()
    }

    func setup(container: View) {
        container.addSubview(_builderView)
        
        _builderView.layout.makeConstraints { make in
            make.edges == container
        }

        setupEvents()
    }

    func setupEvents() {
        _builderView.mouseDown.addListener(weakOwner: self) { [_controller] (_, event) in
            _controller.onMouseDown(event)
        }
        _builderView.mouseMoved.addListener(weakOwner: self) { [_controller] (_, event) in
            _controller.onMouseMove(event)
        }
        _builderView.mouseUp.addListener(weakOwner: self) { [_controller] (_, event) in
            _controller.onMouseUp(event)
        }
        _builderView.mouseClicked.addListener(weakOwner: self) { [_controller] (_, event) in
            _controller.onMouseClick(event)
        }
        _builderView.mouseWheelScrolled.addListener(weakOwner: self) { [_controller] (_, event) in
            _controller.onMouseWheel(event)
        }
    }

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {

    }

    func rendererChanged<T: RendererType>(anyRenderer: T) {

    }

    func mouseMoved(event: MouseEventArgs) {

    }
}

extension SceneGraphBuilderComponent: SceneGraphBuilderViewDelegate {
    @discardableResult
    func openDialog(_ view: UIDialog, location: UIDialogInitialLocation) -> Bool {
        delegate?.openDialog(view, location: location) ?? false
    }
}
