import ImagineUI
import Blend2DRenderer
import GeometriaAppLib

class SceneGraphNodeView: RootView {
    private let _headerView: HeaderView = HeaderView()
    private let _contentsLayoutGuide: LayoutGuide = LayoutGuide()

    private let _inputsStackView: StackView = StackView(orientation: .vertical)
    private let _inputsLabel: LabelControl = LabelControl(textColor: .gray)
    private var _inputViews: [InputView] = []

    private let _outputsStackView: StackView = StackView(orientation: .vertical)
    private let _outputsLabel: LabelControl = LabelControl(textColor: .gray)
    private var _outputViews: [OutputView] = []

    var node: SceneGraphNode

    init(node: SceneGraphNode) {
        self.node = node

        super.init()

        initialize()
        reloadDisplay()
    }

    private func initialize() {
        cacheAsBitmap = false
        
        strokeWidth = 2
        cornerRadius = 4

        _inputsLabel.text = "inputs:"
        _outputsLabel.text = "outputs:"

        _inputsStackView.alignment = .leading
        _outputsStackView.alignment = .trailing

        updateColors()
    }

    private func updateColors() {
        backColor = Color(red: 37, green: 37, blue: 38)
        
        switch controlState {
        case .normal:
            strokeColor = Color(red: 9, green: 71, blue: 113)

        case .highlighted:
            strokeColor = Color(red: 9, green: 71, blue: 113).faded(towards: .white, factor: 0.1)

        default:
            break
        }

        _inputsLabel.backColor = .transparentBlack
        _outputsLabel.backColor = .transparentBlack
    }

    override func onStateChanged(_ change: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(change)

        updateColors()
    }

    override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_headerView)
        addLayoutGuide(_contentsLayoutGuide)
        addSubview(_inputsStackView)
        addSubview(_outputsStackView)
    }

    override func setupConstraints() {
        super.setupConstraints()

        areaIntoConstraintsMask = [.location]

        _inputsLabel.textInset = UIEdgeInsets(left: 5)
        _outputsLabel.textInset = UIEdgeInsets(right: 5)

        _headerView.layout.makeConstraints { make in
            make.left == self + 4
            make.top == self + 4
            make.right == self - 4
        }
        _contentsLayoutGuide.layout.makeConstraints { make in
            make.top == _headerView.layout.bottom + 4
            make.left == self
            make.right == self
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

    override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if let mouseEvent = eventRequest as? MouseEventRequest {
            switch mouseEvent.eventType {
            case .mouseDown, .mouseUp, .mouseClick, .mouseDoubleClick:
                return false
            default:
                break
            }
        }

        return super.canHandle(eventRequest)
    }

    /// Returns the view for the connection point of an input at a specified index
    /// on the underlying graph node.
    ///
    /// - precondition: `index >= 0 && index < node.inputs.count`
    func inputViewConnection(forInputIndex index: Int) -> (View, SceneGraphNodeInput) {
        let view = _inputViews[index]

        return (view.connectionView, view.input)
    }

    /// Returns the view for the connection point of an output at a specified
    /// index on the underlying graph node.
    ///
    /// - precondition: `output >= 0 && output < node.outputs.count`
    func outputViewConnection(forOutputIndex index: Int) -> (View, SceneGraphNodeOutput) {
        let view = _outputViews[index]

        return (view.connectionView, view.output)
    }

    func inputViewConnection(under point: UIPoint) -> (View, SceneGraphNodeInput)? {
        for input in _inputViews {
            let view = input.connectionView

            let converted = view.convert(point: point, from: self)
            if view.contains(point: converted) {
                return (view, input.input)
            }
        }

        return nil
    }

    func outputViewConnection(under point: UIPoint) -> (View, SceneGraphNodeOutput)? {
        for output in _outputViews {
            let view = output.connectionView

            let converted = view.convert(point: point, from: self)
            if view.contains(point: converted) {
                return (view, output.output)
            }
        }

        return nil
    }

    private func reloadDisplay() {
        _headerView.icon = node.displayInformation.icon
        _headerView.title = node.displayInformation.title

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

    /// Allows interacting with the underlying UI state of an input of a node view.
    public class InputViewState {
        @Observable
        fileprivate var connectionCount: Int = 0

        /// Reports that a connection has been made visually.
        public func connectionAdded() {
            connectionCount += 1
        }

        /// Reports that a connection has been removed visually.
        public func connectionRemoved() {
            connectionCount -= 1
        }
    }

    /// Allows interacting with the underlying UI state of an output of a node view.
    public class OutputViewState {
        @Observable
        fileprivate var connectionCount: Int = 0

        /// Reports that a connection has been made visually.
        public func connectionAdded() {
            connectionCount += 1
        }

        /// Reports that a connection has been removed visually.
        public func connectionRemoved() {
            connectionCount -= 1
        }
    }

    private class InputView: View {
        let label: Label = Label(textColor: .white)
        let connectionView: ConnectionView = ConnectionView(connectionDirection: .left)

        var state: InputViewState = InputViewState()

        var input: SceneGraphNodeInput

        init(input: SceneGraphNodeInput) {
            self.input = input

            super.init()

            reloadDisplay()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(label)
            addSubview(connectionView)
        }

        override func setupConstraints() {
            super.setupConstraints()

            connectionView.layout.makeConstraints { make in
                make.left == self
                make.centerY == self
                make.height <= self
            }
            label.layout.makeConstraints { make in
                make.top == self + 2
                make.left == connectionView.layout.right + 4
                make.right == self - 2
                make.bottom == self - 2
            }
        }

        func reloadDisplay() {
            label.text = input.name
            if !input.required {
                connectionView.tooltip = formatTooltip("\(symbol: input.name): \(input.type) \(muted: "optional")")
            } else {
                connectionView.tooltip = formatTooltip("\(symbol: input.name): \(input.type)")
            }
        }
    }

    private class OutputView: View {
        let label: Label = Label(textColor: .white)
        let connectionView: ConnectionView = ConnectionView(connectionDirection: .right)

        var state: OutputViewState = OutputViewState()

        var output: SceneGraphNodeOutput

        init(output: SceneGraphNodeOutput) {
            self.output = output

            super.init()

            reloadDisplay()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(label)
            addSubview(connectionView)
        }

        override func setupConstraints() {
            super.setupConstraints()

            connectionView.layout.makeConstraints { make in
                make.right == self
                make.centerY == self
                make.height <= self
            }
            label.layout.makeConstraints { make in
                make.top == self + 2
                make.left == self + 2
                make.right == connectionView.layout.left - 4
                make.bottom == self - 2
            }
        }

        func reloadDisplay() {
            label.text = output.name
            connectionView.tooltip = formatTooltip("\(symbol: output.name): \(output.type)")
        }
    }

    private class ConnectionView: ControlView {
        private let _circleRadius: Double = 6.0
        private let _leadingLineLength: Double = 5.0

        override var intrinsicSize: UISize? {
            return .init(repeating: _circleRadius) * 2 + .init(width: _leadingLineLength, height: 0.0)
        }

        var connectionState: ConnectionState = .none {
            didSet {
                invalidateControlGraphics()
            }
        }

        var connectionDirection: ConnectionDirection

        init(connectionDirection: ConnectionDirection) {
            self.connectionDirection = connectionDirection

            super.init()

            initialize()
            updateColors()
        }

        private func initialize() {
            strokeColor = .gray
            strokeWidth = 2
        }

        override func renderBackground(in renderer: Renderer, screenRegion: ClipRegionType) {
            // Compute geometry
            var circle = UICircle(center: .init(x: 0, y: size.height / 2), radius: _circleRadius)

            var leadingLine = UILine(
                x1: 0,
                y1: circle.center.y,
                x2: 0,
                y2: circle.center.y
            )
            
            switch connectionDirection {
            case .left:
                circle.center.x = size.width - _circleRadius
                leadingLine.start.x = 0
                leadingLine.end.x = _leadingLineLength
            case .right:
                circle.center.x = _circleRadius
                leadingLine.start.x = size.width - _leadingLineLength
                leadingLine.end.x = size.width
            }

            // Stroke circle
            renderer.setStroke(strokeColor)
            renderer.setStrokeWidth(strokeWidth)
            renderer.stroke(circle)

            // Stroke connection line
            renderer.setStroke(strokeColor)
            renderer.setStrokeWidth(strokeWidth)
            renderer.stroke(leadingLine)
        }

        override func onStateChanged(_ change: ValueChangedEventArgs<ControlViewState>) {
            super.onStateChanged(change)

            updateColors()
        }

        override func canHandle(_ eventRequest: EventRequest) -> Bool {
            if let mouseEvent = eventRequest as? MouseEventRequest {
                switch mouseEvent.eventType {
                case .mouseDown, .mouseUp, .mouseClick, .mouseDoubleClick:
                    return false
                default:
                    break
                }
            }

            return super.canHandle(eventRequest)
        }

        private func updateColors() {
            switch controlState {
            case .normal:
                strokeWidth = 1
            case .highlighted:
                strokeWidth = 2
            default:
                break
            }
        }

        enum ConnectionState {
            case none
            case connected(SceneGraphNode.Connection)
        }

        enum ConnectionDirection {
            case left
            case right
        }
    }

    private class HeaderView: View {
        private let _iconView: ImageView = ImageView(image: nil)
        private let _label: Label = Label(textColor: .white)
        private let _titleSeparator: ControlView = ControlView()
        private let _stackView: StackView = StackView(orientation: .horizontal)

        var title: String {
            get {
                return _label.text
            }
            set {
                _label.text = newValue
            }
        }

        var icon: Image? {
            get {
                return _iconView.image
            }
            set {
                _iconView.image = newValue
                _updateStackView()
            }
        }

        override init() {
            super.init()

            _titleSeparator.isInteractiveEnabled = false
            _titleSeparator.backColor = .lightGray

            _updateStackView()
        }

        override func setupHierarchy() {
            super.setupHierarchy()
            
            _iconView.areaIntoConstraintsMask = []

            addSubview(_stackView)
            addSubview(_titleSeparator)
            _stackView.addArrangedSubview(_label)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _stackView.layout.makeConstraints { make in
                (make.left, make.top, make.right) == self
            }
            _titleSeparator.layout.makeConstraints { make in
                make.top == _stackView.layout.bottom + 2
                make.height == 1
                (make.left, make.bottom, make.right) == self
            }
        }

        private func _updateStackView() {
            _iconView.removeFromSuperview()

            if _iconView.image != nil {
                _stackView.insertArrangedSubview(_iconView, at: 0)
            }
        }
    }
}

private func formatTooltip(_ tooltip: FormattedInterpolatedString) -> Tooltip {
    return .init(text: tooltip.result)
}

private struct FormattedInterpolatedString: ExpressibleByStringInterpolation {
    static var monoFont: Font = {
        // TODO: Make this font loading renderer-agnostic
        let context = Blend2DRendererContext()
        let fontPath = GeometriaAppLib.Resources.bundle.path(forResource: "FiraCode-Bold", ofType: "ttf")!

        let fontFace = try! context.fontManager.loadFontFace(fromPath: fontPath)

        return fontFace.font(withSize: 12)
    }()

    var result: AttributedText

    init(stringLiteral value: String) {
        result = AttributedText(value)
    }

    init(stringInterpolation: StringInterpolation) {
        result = stringInterpolation.output
    }

    struct StringInterpolation: StringInterpolationProtocol {
        var output: AttributedText = ""

        init(literalCapacity: Int, interpolationCount: Int) {
            output.reserveCapacity(segmentCount: interpolationCount)
        }

        mutating func appendLiteral(_ literal: String) {
            output.append(literal)
        }

        mutating func appendInterpolation<T>(_ literal: T, attributes: AttributedText.Attributes) {
            output.append("\(literal)", attributes: attributes)
        }

        mutating func appendInterpolation(_ literal: SceneNodeDataType) {
            output.append("\(literal)", attributes: [.foregroundColor: Color.fuchsia])
        }

        mutating func appendInterpolation<T>(muted literal: T) {
            output.append("\(literal)", attributes: [.foregroundColor: Color.gray])
        }

        mutating func appendInterpolation<T>(symbol literal: T) {
            output.append("\(literal)", attributes: [.font: FormattedInterpolatedString.monoFont])
        }

        mutating func appendInterpolation<T>(_ literal: T) {
            output.append("\(literal)")
        }
    }
}
