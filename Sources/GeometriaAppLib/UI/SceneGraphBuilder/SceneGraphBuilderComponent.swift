import Foundation
import ImagineUI
import Blend2DRenderer

class SceneGraphBuilderComponent: RaytracerUIComponent {
    private let builderView: SceneGraphBuilderView = SceneGraphBuilderView()

    weak var delegate: RaytracerUIComponentDelegate?

    init() {

    }

    func setup(container: View) {
        container.addSubview(builderView)
        builderView.layout.makeConstraints { make in
            make.edges == container
        }
    }

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {

    }

    func rendererChanged<T: RendererType>(anyRenderer: T) {
        
    }

    func mouseMoved(event: MouseEventArgs) {

    }
}
