protocol SceneGraphDelegate {
    func getValue(for node: SceneGraphNode, input: Int) throws -> Any
    func getTypedValue<T>(for node: SceneGraphNode, input: Int) throws -> T
    func getTypedValue<T>(for node: SceneGraphNode, input: SceneGraphNode.Input<T>) throws -> T
    func getValue(for connection: SceneGraphNode.Connection) throws -> Any

    func hasInput(node: SceneGraphNode, input: Int) -> Bool
}
