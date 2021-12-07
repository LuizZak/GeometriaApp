import ImagineUI

class SceneGraphBuilderView: RootView {
    private var nodeViews: [SceneGraphNodeView] = []

    weak var delegate: SceneGraphBuilderViewDelegate?

    override init() {
        super.init()
        initialize()
    }

    private func initialize() {
        backColor = Color(red: 37, green: 37, blue: 38)

        let node = AABBGraphNode(aabb: .init(minimum: .zero, maximum: .one), material: .defaultMaterial)
        _addNode(node)
    }

    private func _addNode(_ node: SceneGraphNode) {
        let view = SceneGraphNodeView(node: node)

        addSubview(view)
        nodeViews.append(view)

        _setupEvents(view)
    }

    private func _setupEvents(_ view: SceneGraphNodeView) {
        view.mouseDown.addListener(owner: self) { (view, _) in 
            view.bringToFrontOfSuperview()
        }
    }
}

protocol SceneGraphBuilderViewDelegate: AnyObject {

}

private class SceneGraphNodeView: RootView {
    private var _mouseDown = false
    private var _mouseDownPoint: UIVector = .zero

    private let _label: Label = Label(textColor: .white)
    private let _titleSeparator: ControlView = ControlView()
    private let _contentsLayoutGuide: LayoutGuide = LayoutGuide()

    private let _inputsStackView: StackView = StackView(orientation: .vertical)
    private let _inputsLabel: Label = Label(textColor: .gray)
    private var _inputViews: [InputView] = []

    private let _outputsStackView: StackView = StackView(orientation: .vertical)
    private let _outputsLabel: Label = Label(textColor: .gray)
    private var _outputViews: [OutputView] = []

    var node: SceneGraphNode

    init(node: SceneGraphNode) {
        self.node = node

        super.init()

        initialize()
        reloadDisplay()
    }

    private func initialize() {
        strokeColor = Color(red: 9, green: 71, blue: 113)
        strokeWidth = 2
        cornerRadius = 4

        _titleSeparator.isInteractiveEnabled = false
        _titleSeparator.backColor = .lightGray

        _inputsLabel.text = "inputs:"
        _outputsLabel.text = "outputs:"

        _inputsStackView.alignment = .leading
        _outputsStackView.alignment = .trailing
    }

    override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_label)
        addSubview(_titleSeparator)
        addLayoutGuide(_contentsLayoutGuide)
        addSubview(_inputsStackView)
        addSubview(_outputsStackView)
    }

    override func setupConstraints() {
        super.setupConstraints()

        areaIntoConstraintsMask = [.location]

        _label.layout.makeConstraints { make in
            make.left == self + 4
            make.top == self + 4
            make.right <= self - 4
        }
        _titleSeparator.layout.makeConstraints { make in
            make.top == _label.layout.bottom + 2
            make.left == self + 4
            make.right == self - 4
            make.height == 1
        }
        _contentsLayoutGuide.layout.makeConstraints { make in
            make.top == _titleSeparator.layout.bottom + 4
            make.left == self + 4
            make.right == self - 4
            make.bottom == self - 4
        }
        _inputsStackView.layout.makeConstraints { make in
            (make.left, make.top) == _contentsLayoutGuide
            make.right <= _contentsLayoutGuide - 8
        }
        _outputsStackView.layout.makeConstraints { make in
            make.top == _inputsStackView.layout.bottom + 2
            make.left >= _contentsLayoutGuide + 8
            make.right == _contentsLayoutGuide
            make.bottom <= _contentsLayoutGuide
        }
    }

    public override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        _mouseDownPoint = event.location
        _mouseDown = true
    }

    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)

        if _mouseDown {
            performDrag(event)
        }
    }

    public override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        _mouseDown = false
    }

    private func performDrag(_ event: MouseEventArgs) {
        let mouseLocation = convert(point: event.location, to: nil)

        location = mouseLocation - _mouseDownPoint
    }

    private func reloadDisplay() {
        _label.text = node.displayInformation.title

        reloadInputs()
        reloadOutputs()
    }

    private func reloadInputs() {
        _inputsLabel.removeFromSuperview()
        for view in _inputViews {
            view.removeFromSuperview()
        }

        _inputViews.removeAll()

        guard !node.inputs.isEmpty else {
            return
        }

        _inputsStackView.addArrangedSubview(_inputsLabel)

        for input in node.inputs {
            let view = InputView(input: input)
            _inputsStackView.addArrangedSubview(view)
            _inputViews.append(view)
        }
    }

    private func reloadOutputs() {
        _outputsLabel.removeFromSuperview()
        for view in _outputViews {
            view.removeFromSuperview()
        }

        _outputViews.removeAll()

        guard !node.outputs.isEmpty else {
            return
        }

        _outputsStackView.addArrangedSubview(_outputsLabel)

        _outputViews.removeAll()

        for output in node.outputs {
            let view = OutputView(output: output)
            _outputsStackView.addArrangedSubview(view)
            _outputViews.append(view)
        }
    }

    private class InputView: View {
        private let _label: Label = Label(textColor: .white)
        private let _connection: ConnectionView = ConnectionView()

        var input: SceneGraphNode.Input

        init(input: SceneGraphNode.Input) {
            self.input = input

            super.init()

            reloadDisplay()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_label)
            addSubview(_connection)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _connection.layout.makeConstraints { make in
                make.left == self + 2
                make.centerY == self
                make.height <= self
            }
            _label.layout.makeConstraints { make in
                make.top == self + 2
                make.left == _connection.layout.right + 4
                make.right == self - 2
                make.bottom == self - 2
            }
        }

        func reloadDisplay() {
            _label.text = input.name
        }
    }

    private class OutputView: View {
        private let _label: Label = Label(textColor: .white)
        private let _connection: ConnectionView = ConnectionView()

        var output: SceneGraphNode.Output

        init(output: SceneGraphNode.Output) {
            self.output = output

            super.init()

            reloadDisplay()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_label)
            addSubview(_connection)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _connection.layout.makeConstraints { make in
                make.right == self - 2
                make.centerY == self
                make.height <= self
            }
            _label.layout.makeConstraints { make in
                make.top == self + 2
                make.left == self + 2
                make.right == _connection.layout.left - 4
                make.bottom == self - 2
            }
        }

        func reloadDisplay() {
            _label.text = output.name
        }
    }

    private class ConnectionView: ControlView {
        private let _circleRadius: Double = 6.0
        
        override var intrinsicSize: UISize? {
            return .init(repeating: _circleRadius) * 2
        }

        override init() {
            super.init()

            initialize()
            updateColors()
        }

        private func initialize() {
            strokeColor = .gray
            strokeWidth = 2
        }

        override func renderBackground(in renderer: Renderer, screenRegion: ClipRegion) {
            let circle = UICircle(center: size.asUIPoint / 2, radius: _circleRadius)

            renderer.setStroke(strokeColor)
            renderer.setStrokeWidth(strokeWidth)
            renderer.stroke(circle)
        }

        override func onStateChanged(_ change: ValueChangedEventArgs<ControlViewState>) {
            super.onStateChanged(change)

            updateColors()
        }

        private func updateColors() {
            switch currentState {
            case .normal:
                strokeWidth = 1
            case .highlighted:
                strokeWidth = 2
            default:
                break
            }
        }
    }
}