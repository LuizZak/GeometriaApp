import ImagineUI
import Blend2DRenderer

class SceneGraphBuilderView: RootView {
    private var _sidePanel: SidePanel = SidePanel(pinSide: .left, length: 250)
    private var _nodesContainer: NodesContainer = NodesContainer()
    private var _mouseState: MouseState = .none
    private var _nodeViews: [SceneGraphNodeView] = []

    weak var delegate: SceneGraphBuilderViewDelegate?

    override init() {
        super.init()

        initialize()
    }

    private func initialize() {
        cacheAsBitmap = false

        backColor = Color(red: 37, green: 37, blue: 38)

        let node1 = AABBGraphNode(aabb: .init(minimum: .zero, maximum: .one), material: .defaultMaterial)
        _addNode(node1).location = .init(x: 300, y: 100)
        let node2 = RaymarchingSceneNode()
        _addNode(node2).location = .init(x: 350, y: 200)
        let node3 = RaymarcherNode()
        _addNode(node3).location = .init(x: 550, y: 210)
    }

    override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_nodesContainer)
        addSubview(_sidePanel)
    }

    override func setupConstraints() {
        super.setupConstraints()

        _nodesContainer.layout.makeConstraints { layout in
            layout.edges == self
        }
    }

    override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if let mouseEvent = eventRequest as? MouseEventRequest, mouseEvent.eventType == MouseEventType.mouseWheel {
            return true
        }

        return super.canHandle(eventRequest)
    }

    override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        if event.buttons == .left {
            if let node = _nodeUnder(point: event.location) {
                node.bringToFrontOfSuperview()
                
                _mouseState = .draggingNode(
                    ViewDragOperation(
                        view: node,
                        container: _nodesContainer,
                        offset: node.convert(point: event.location, from: self)
                    )
                )
            } else {
                _mouseState = .draggingViewport(initialOffset: event.location - _nodesContainer.translation)
            }
        }
    }

    override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)

        switch _mouseState {
        case .none:
            break
        case .draggingViewport(let offset):
            _nodesContainer.translation = event.location - offset
        case .draggingNode(let operation):
            let point = operation.container.convert(point: event.location, from: self)
            operation.view.location = point - operation.offset
        }
    }

    override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        _mouseState = .none
    }

    override func onMouseClick(_ event: MouseEventArgs) {
        super.onMouseClick(event)

        if event.buttons == .right, let node = _nodeUnder(point: event.location) {
            _openContextMenu(for: node, location: convert(point: event.location, to: nil))
        }
    }

    override func onMouseWheel(_ event: MouseEventArgs) {
        super.onMouseWheel(event)

        if event.delta.y > 0 {
            _nodesContainer.zoom = min(2.0, _nodesContainer.zoom + 0.1)
        } else {
            _nodesContainer.zoom = max(0.25, _nodesContainer.zoom - 0.1)
        }
    }

    @discardableResult
    private func _addNode(_ node: SceneGraphNode) -> SceneGraphNodeView {
        let view = SceneGraphNodeView(node: node)

        _nodesContainer.addSubview(view)
        _nodeViews.append(view)

        return view
    }

    private func _removeNodeView(_ view: SceneGraphNodeView) {
        guard let index = _nodeViews.firstIndex(of: view) else { return }

        view.removeFromSuperview()
        _nodeViews.remove(at: index)
    }

    private func _openContextMenu(for view: SceneGraphNodeView, location: UIPoint) {
        delegate?.openDialog(
            ContextMenuView.create {
                ContextMenuItem(title: "Delete") {
                    self._removeNodeView(view)
                }
            },
            location: .topLeft(location)
        )
    }

    private func _nodeUnder(point: UIPoint) -> SceneGraphNodeView? {
        for node in _nodeViews {
            let converted = node.convert(point: point, from: self)
            if node.contains(point: converted) {
                return node
            }
        }

        return nil
    }

    /// A view that acts as an infinitely-bounded view for node containment,
    /// with dedicated.
    private class NodesContainer: View {
        var translation: UIVector = .zero {
            willSet {
                invalidate()
            }
            didSet {
                invalidate()
            }
        }

        var zoom: Double {
            get {
                min(scale.x, scale.y)
            }
            set {
                scale = .init(repeating: newValue)
            }
        }

        override var transform: UIMatrix {
            UIMatrix.transformation(
                xScale: scale.x,
                yScale: scale.y,
                angle: rotation,
                xOffset: (location.x + translation.x),
                yOffset: (location.y + translation.y)
            )
        }

        override init() {
            super.init()

            clipToBounds = false
        }

        override func contains(point: UIVector, inflatingArea: UIVector = .zero) -> Bool {
            return true
        }

        override func intersects(area: UIRectangle, inflatingArea: UIVector = .zero) -> Bool {
            return true
        }

        override func boundsForRedraw() -> UIRectangle {
            UIRectangle.union(subviews.map { view in
                convert(bounds: view.boundsForRedraw(), from: view)
            })
        }
    }

    private enum MouseState {
        case none
        case draggingViewport(initialOffset: UIVector)
        case draggingNode(ViewDragOperation)
    }

    private struct ViewDragOperation {
        /// View being dragged.
        var view: View

        /// The container for the view being dragged, aka its `superview` at the
        /// time of drag operation creation.
        var container: View

        /// Offset from view's `location` that the drag occurs.
        var offset: UIVector
    }
}

protocol SceneGraphBuilderViewDelegate: AnyObject {
    /// Request that the UI open a view as a dialog, obscuring the underlying
    /// views while the view is displayed.
    ///
    /// Returns a boolean value indicating whether the view was successfully opened.
    @discardableResult
    func openDialog(_ view: UIDialog, location: UIDialogInitialLocation) -> Bool
}

private class SceneGraphNodeView: RootView {
    private let _headerView: HeaderView = HeaderView()
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
        cacheAsBitmap = false
        
        backColor = Color(red: 37, green: 37, blue: 38)

        strokeColor = Color(red: 9, green: 71, blue: 113)
        strokeWidth = 2
        cornerRadius = 4

        _inputsLabel.text = "inputs:"
        _outputsLabel.text = "outputs:"

        _inputsStackView.alignment = .leading
        _outputsStackView.alignment = .trailing
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

        _headerView.layout.makeConstraints { make in
            make.left == self + 4
            make.top == self + 4
            make.right == self - 4
        }
        _contentsLayoutGuide.layout.makeConstraints { make in
            make.top == _headerView.layout.bottom + 4
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

    override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if eventRequest is MouseEventRequest {
            return false
        }

        return super.canHandle(eventRequest)
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

    private class InputView: View {
        private let _label: Label = Label(textColor: .white)
        private let _connectionView: ConnectionView = ConnectionView()

        var input: SceneGraphNodeInput

        init(input: SceneGraphNodeInput) {
            self.input = input

            super.init()

            reloadDisplay()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_label)
            addSubview(_connectionView)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _connectionView.layout.makeConstraints { make in
                make.left == self + 2
                make.centerY == self
                make.height <= self
            }
            _label.layout.makeConstraints { make in
                make.top == self + 2
                make.left == _connectionView.layout.right + 4
                make.right == self - 2
                make.bottom == self - 2
            }
        }

        func reloadDisplay() {
            _label.text = input.name
            if !input.required {
                _connectionView.tooltip = formatTooltip("\(symbol: input.name): \(input.type) \(muted: "optional")")
            } else {
                _connectionView.tooltip = formatTooltip("\(symbol: input.name): \(input.type)")
            }
        }
    }

    private class OutputView: View {
        private let _label: Label = Label(textColor: .white)
        private let _connectionView: ConnectionView = ConnectionView()

        var output: SceneGraphNodeOutput

        init(output: SceneGraphNodeOutput) {
            self.output = output

            super.init()

            reloadDisplay()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_label)
            addSubview(_connectionView)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _connectionView.layout.makeConstraints { make in
                make.right == self - 2
                make.centerY == self
                make.height <= self
            }
            _label.layout.makeConstraints { make in
                make.top == self + 2
                make.left == self + 2
                make.right == _connectionView.layout.left - 4
                make.bottom == self - 2
            }
        }

        func reloadDisplay() {
            _label.text = output.name
            _connectionView.tooltip = formatTooltip("\(symbol: output.name): \(output.type)")
        }
    }

    private class ConnectionView: ControlView {
        private let _circleRadius: Double = 6.0

        override var intrinsicSize: UISize? {
            return .init(repeating: _circleRadius) * 2
        }

        var connectionState: ConnectionState = .none {
            didSet {
                invalidateControlGraphics()
            }
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
        let fontPath = Resources.bundle.path(forResource: "FiraCode-Bold", ofType: "ttf")!

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
