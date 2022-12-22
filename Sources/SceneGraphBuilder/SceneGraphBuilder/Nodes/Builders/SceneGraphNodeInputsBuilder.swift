@resultBuilder
struct SceneGraphNodeInputsBuilder {
    public static func buildExpression<T: SceneNodeDataTypeRepresentable>(_ expression: (T.Type, name: String)) -> InputBuilderStep {
        InputBuilderStep { index in
            SceneGraphNode.Input<T>(name: expression.name, index: index)
        }
    }

    public static func buildExpression<T: SceneNodeDataTypeRepresentable>(_ expression: (SceneGraphNode.Input<T>)) -> InputBuilderStep {
        InputBuilderStep { _ in
            expression
        }
    }

    public static func buildBlock() -> [InputBuilderStep] {
        []
    }

    public static func buildBlock(_ components: InputBuilderStep...) -> [InputBuilderStep] {
        components
    }

    public static func buildFinalResult(_ component: [InputBuilderStep]) -> [SceneGraphNodeInput] {
        component.enumerated().map { (index, builder) in
            builder.build(index: index)
        }
    }

    struct InputBuilderStep {
        private let builder: (Int) -> SceneGraphNodeInput

        init(_ builder: @escaping (Int) -> SceneGraphNodeInput) {
            self.builder = builder
        }

        func build(index: Int) -> SceneGraphNodeInput {
            builder(index)
        }
    }
}
