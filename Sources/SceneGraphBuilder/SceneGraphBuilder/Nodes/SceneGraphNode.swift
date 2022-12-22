import ImagineUI

/// Base class for scene graph nodes.
public class SceneGraphNode {
    /// Static display information that is generic across all instances of this
    /// particular `SceneGraphNode`'s type.
    public class var staticDisplayInformation: DisplayInformation {
        DisplayInformation(title: "Generic node")
    }

    public var displayInformation: DisplayInformation {
        DisplayInformation(title: "Generic node")
    }
    
    public var inputs: [SceneGraphNodeInput] { [] }
    public var outputs: [SceneGraphNodeOutput] { [] }

    init() {

    }

    public func makeElement(_ delegate: SceneGraphDelegate) throws -> Any {
        throw MakeElementError.notImplemented
    }

    /// Errors raised when calling `SceneGraphNode.makeElement()`
    public enum MakeElementError: Error {
        case notImplemented
    }

    public struct DisplayInformation {
        var title: String
        var icon: Image?
    }

    public struct Input<T: SceneNodeDataTypeRepresentable>: SceneGraphNodeInput {
        public var name: String
        public var index: Int
        public var type: SceneNodeDataType
        public var required: Bool = true

        public init(
            name: String, index: Int,
            type: SceneNodeDataType = T.staticDataType,
            required: Bool = true
        ) {
            
            self.name = name
            self.index = index
            self.type = type
            self.required = required
        }
    }

    public struct Output<T: SceneNodeDataTypeRepresentable>: SceneGraphNodeOutput {
        public var name: String
        public var index: Int
        public var type: SceneNodeDataType

        public init(
            name: String,
            index: Int,
            type: SceneNodeDataType = T.staticDataType
        ) {

            self.name = name
            self.index = index
            self.type = type
        }
    }

    public enum Connection {
        case node(from: SceneGraphNode, outputIndex: Int, inputIndex: Int)
        case `static`(SceneNodeDataTypeRepresentable, inputIndex: Int)
    }
}

public protocol SceneGraphNodeInput {
    var name: String { get }
    var index: Int { get }
    var type: SceneNodeDataType { get }
    var required: Bool { get }
}

public protocol SceneGraphNodeOutput {
    var name: String { get }
    var index: Int { get }
    var type: SceneNodeDataType { get }
}
