import ImagineUI

/// Base class for scene graph nodes.
class SceneGraphNode {
    var displayInformation: DisplayInformation {
        DisplayInformation(title: "Generic node")
    }
    var connections: [Connection] = []
    var inputs: [Input] { [] }
    var outputs: [Output] { [] }

    init() {

    }

    func canConnect(from node: SceneGraphNode, outputIndex: Int, inputIndex: Int) -> Bool {
        return DataType.areAssignable(source: node.outputs[outputIndex].type, target: inputs[inputIndex].type)
    }

    func connect(from node: SceneGraphNode, outputIndex: Int, inputIndex: Int) -> Bool {
        guard canConnect(from: node, outputIndex: outputIndex, inputIndex: inputIndex) else {
            return false
        }

        connections.append(.node(node, outputIndex: outputIndex, inputIndex: inputIndex))

        return true
    }

    func makeElement() throws -> AnyElement {
        throw MakeElementError.notImplemented
    }

    static func canConnect(from source: SceneGraphNode, outputIndex: Int, to target: SceneGraphNode, inputIndex: Int) -> Bool {
        return DataType.areAssignable(source: source.outputs[outputIndex].type, target: target.inputs[inputIndex].type)
    }

    /// Errors raised when calling `SceneGraphNode.makeElement()`
    enum MakeElementError: Error {
        case notImplemented
    }

    struct DisplayInformation {
        var icon: Image?
        var title: String
    }

    struct Input {
        var name: String
        var type: DataType
    }

    struct Output {
        var name: String
        var type: DataType
    }

    enum DataType: Hashable {
        case geometry
        case anyElement

        static func areAssignable(source: DataType, target: DataType) -> Bool {
            switch (source, target) {
            case (.geometry, .anyElement):
                return true
            case (.anyElement, .anyElement):
                return true
            default:
                return false
            }
        }
    }

    enum Connection {
        case node(SceneGraphNode, outputIndex: Int, inputIndex: Int)
    }
}
