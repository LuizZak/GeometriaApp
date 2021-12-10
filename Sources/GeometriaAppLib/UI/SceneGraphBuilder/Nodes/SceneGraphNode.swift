import ImagineUI

/// Base class for scene graph nodes.
class SceneGraphNode {
    var displayInformation: DisplayInformation {
        DisplayInformation(title: "Generic node")
    }
    
    var inputs: [SceneGraphNodeInput] { [] }
    var outputs: [SceneGraphNodeOutput] { [] }

    init() {

    }

    func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        throw MakeElementError.notImplemented
    }

    /// Errors raised when calling `SceneGraphNode.makeElement()`
    enum MakeElementError: Error {
        case notImplemented
    }

    struct DisplayInformation {
        var icon: Image?
        var title: String
    }

    struct Input<T: SceneNodeDataTypeRepresentable>: SceneGraphNodeInput {
        var name: String
        var index: Int
        var type: SceneNodeDataType
        var required: Bool = true

        init(name: String, index: Int, type: SceneNodeDataType = T.staticDataType, required: Bool = true) {
            self.name = name
            self.index = index
            self.type = type
            self.required = required
        }
    }

    struct Output<T: SceneNodeDataTypeRepresentable>: SceneGraphNodeOutput {
        var name: String
        var index: Int
        var type: SceneNodeDataType

        init(name: String, index: Int, type: SceneNodeDataType = T.staticDataType) {
            self.name = name
            self.index = index
            self.type = type
        }
    }

    enum Connection {
        case node(from: SceneGraphNode, outputIndex: Int, inputIndex: Int)
        case `static`(SceneNodeDataTypeRepresentable, inputIndex: Int)
    }
}

protocol SceneGraphNodeInput {
    var name: String { get }
    var index: Int { get }
    var type: SceneNodeDataType { get }
    var required: Bool { get }
}

protocol SceneGraphNodeOutput {
    var name: String { get }
    var index: Int { get }
    var type: SceneNodeDataType { get }
}
