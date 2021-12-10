@resultBuilder
struct SceneGraphNodeInputsBuilder {
    static func buildExpression<T: SceneNodeDataTypeRepresentable>(_ expression: (T.Type, name: String)) -> InputBuilderStep {
        InputBuilderStep { index in
            SceneGraphNode.Input<T>(name: expression.name, index: index)
        }
    }

    static func buildExpression<T: SceneNodeDataTypeRepresentable>(_ expression: (SceneGraphNode.Input<T>)) -> InputBuilderStep {
        InputBuilderStep { _ in
            expression
        }
    }

    static func buildBlock() -> [InputBuilderStep] {
        []
    }

    static func buildBlock(_ components: InputBuilderStep...) -> [InputBuilderStep] {
        components
    }

    static func buildFinalResult(_ component: [InputBuilderStep]) -> [SceneGraphNodeInput] {
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
