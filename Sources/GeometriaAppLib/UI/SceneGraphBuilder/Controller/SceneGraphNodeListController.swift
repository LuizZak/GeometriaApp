import ImagineUI

public typealias NodeInstantiationClosure = (NodeInstantiationContext) throws -> SceneGraphNode

/// Controls lists of instantiable scene graph nodes.
public class SceneGraphNodeListController {
    var entries: [NodeEntry] = []

    public init() {

    }

    public func addNodeEntry(_ entry: NodeEntry) {
        entries.append(entry)
    }

    /// Adds a specified node type to the list of nodes on this list controller.
    public func addStaticNodeType<T: InitializableSceneGraphNode>(type: T.Type) {
        let display = T.staticDisplayInformation

        let entry = NodeEntry(
            title: .init(display.title),
            icon: display.icon,
            instantiate: { _ in T.init() }
        )

        addNodeEntry(entry)
    }

    public static func defaultNodeListController() -> SceneGraphNodeListController {
        let controller = SceneGraphNodeListController()

        controller.addStaticNodeType(type: CameraNode.self)
        controller.addStaticNodeType(type: RaymarcherNode.self)
        controller.addStaticNodeType(type: RaymarchingSceneNode.self)

        return controller
    }

    /// Contains display information about an instantiable scene graph node.
    public struct NodeEntry {
        /// A textual title for the item in UI display lists.
        public var title: AttributedText

        /// An optional icon for the node.
        public var icon: Image?

        /// Instantiator for creating new nodes of this type.
        public var instantiate: NodeInstantiationClosure
    }
}

/// Provides support for requesting inputs in UI before instantiating a `SceneGraphNode`.
public protocol NodeInstantiationType {
    /// Reports that an input type is required in order to produce a value.
    mutating func requireInputType<T>(label: String, type: T.Type) throws

    /// Reports that an input type may optionally be provided to produce a value.
    mutating func optionalInputType<T>(label: String, type: T.Type) throws

    /// Provides a closure that takes in input values and returns a final instantiable
    /// `T` with the input values from an instantiation context.
    ///
    /// May throw errors during creation, to indicate issues while attempting to
    /// instantiate an object.
    func onFullfil<T>(_ closure: (NodeInstantiationContext) throws -> T) throws -> T
}
