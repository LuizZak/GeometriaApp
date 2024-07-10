public protocol SceneGraphDelegate {
    func getValue(for node: SceneGraphNode, input: Int) throws -> Any
    func getTypedValue<T>(for node: SceneGraphNode, input: Int) throws -> T
    func getTypedValue<T>(for node: SceneGraphNode, input: SceneGraphNode.Input<T>) throws -> T
    func getValue(for connection: SceneGraphNode.Connection) throws -> Any

    func hasInput(node: SceneGraphNode, input: Int) -> Bool
}

extension SceneGraphDelegate {
    func getTypedValue<T>(for node: SceneGraphNode, input: Int) throws -> T {
        guard let value = try getValue(for: node, input: input) as? T else {
            throw SceneGraphDelegateError.invalidType(expected: T.self)
        }

        return value
    }
    func getTypedValue<T>(for node: SceneGraphNode, input: SceneGraphNode.Input<T>) throws -> T {
        guard let value = try getValue(for: node, input: input.index) as? T else {
            throw SceneGraphDelegateError.invalidType(expected: T.self)
        }

        return value
    }
}

enum SceneGraphDelegateError: Swift.Error {
    case invalidType(expected: Any.Type)
    case unconnected
}
