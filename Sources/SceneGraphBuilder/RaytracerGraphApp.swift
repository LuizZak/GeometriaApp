import Foundation
import SwiftBlend2D
import ImagineUI
import Text
import Blend2DRenderer
import GeometriaAppLib

open class RaytracerGraphApp: RaytracerUI {
    let controlsComponent = ControlsComponent()
    let sceneGraphComponent = SceneGraphBuilderComponent()

    public override init(size: UIIntSize) {
        super.init(size: size)

        createUI()
    }

    func createUI() {
        ControlView.globallyCacheAsBitmap = false
        Label.globallyCacheAsBitmap = false

        controlsComponent.controlsDelegate = self
        let controlsContainer = addComponentInReservedView(controlsComponent)

        let sceneGraphContainer = addComponentInReservedView(sceneGraphComponent)

        controlsContainer.layout.makeConstraints { make in
            (make.left, make.top, make.right) == componentsContainer
        }
        sceneGraphContainer.layout.makeConstraints { make in
            make.under(controlsContainer)
            (make.left, make.bottom, make.right) == componentsContainer
        }
    }

    func startRender() {
        guard
            let sceneNode = self.sceneGraphComponent.sceneGraph.nodes.first(where: {
                $0.sceneGraphNode is RaymarchingSceneNode
            })?.sceneGraphNode as? RaymarchingSceneNode
        else {
            // TODO: Show warning dialog
            return
        }

        do {
            _ = try sceneNode.makeElement(sceneGraphComponent.sceneGraph)
        } catch {
            // TODO: Show error dialog
        }
    }
}

extension RaytracerGraphApp: ControlsComponent.Delegate {
    func controlsComponent(
        _ component: ControlsComponent,
        didPressRenderButton button: Button
    ) {
        startRender()
    }
}

extension SceneGraph: SceneGraphDelegate {
    func getValue(for node: SceneGraphNode, input: Int) throws -> Any {
        let outputs = connectedOutputs(node, input: input)
        guard let output = outputs.first else {
            throw SceneGraphDelegateError.unconnected
        }

        return try output.sceneGraphNode.makeElement(self)
    }

    func getValue(for connection: SceneGraphNode.Connection) throws -> Any {
        switch connection {
        case .static(let value, _):
            return value

        case .node(let node, _, let inputIndex):
            return try getValue(for: node, input: inputIndex)
        }
    }

    func hasInput(node: SceneGraphNode, input: Int) -> Bool {
        !connectedOutputs(node, input: input).isEmpty
    }

    func connectedOutputs(_ node: SceneGraphNode, input: Int) -> [Node] {
        guard
            let index = nodes.firstIndex(where: {
                switch $0.element {
                case .input(let sceneNode, let inputInfo)
                    where node === sceneNode && inputInfo.index == input:
                    return true
                default:
                    return false
                }
            })
        else {
            return []
        }

        let inputNode = nodes[index]
        return nodesConnected(towards: inputNode)
    }
}
