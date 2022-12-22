@resultBuilder
struct SceneGraphNodeOutputsBuilder {
    public static func buildExpression<T: SceneNodeDataTypeRepresentable>(_ expression: (T.Type, name: String)) -> OutputBuilderStep {
        OutputBuilderStep { index in
            SceneGraphNode.Output<T>(name: expression.name, index: index)
        }
    }

    public static func buildExpression<T: SceneNodeDataTypeRepresentable>(_ expression: (SceneGraphNode.Output<T>)) -> OutputBuilderStep {
        OutputBuilderStep { _ in
            expression
        }
    }

    public static func buildBlock() -> [OutputBuilderStep] {
        []
    }

    public static func buildBlock(_ components: OutputBuilderStep...) -> [OutputBuilderStep] {
        components
    }

    public static func buildFinalResult(_ component: [OutputBuilderStep]) -> [SceneGraphNodeOutput] {
        component.enumerated().map { (index, builder) in
            builder.build(index: index)
        }
    }

    struct OutputBuilderStep {
        private let builder: (Int) -> SceneGraphNodeOutput

        init(_ builder: @escaping (Int) -> SceneGraphNodeOutput) {
            self.builder = builder
        }

        func build(index: Int) -> SceneGraphNodeOutput {
            builder(index)
        }
    }
}
