import ImagineUI
import Geometry

class SidePanel: ControlView {
    private var _mouseDown: Bool = false
    private var _mouseOffset: Double = 0.0
    private var _lipSize: Double = 4.0
    
    let contentBounds: LayoutGuide = LayoutGuide()

    /// The length of the panel on its superview.
    var length: Double {
        didSet {
            length = max(_lipSize, length)

            setNeedsLayout()
        }
    }

    /// The side of the superview this side panel will pin into.
    var pinSide: PinSide {
        didSet {
            recreateConstraints()
        }
    }

    override var intrinsicSize: UISize? {
        switch pinSide {
        case .left, .right:
            return UISize(width: length, height: 0)
        case .top, .bottom:
            return UISize(width: 0, height: length)
        }
    }

    init(pinSide: PinSide, length: Double) {
        self.length = length
        self.pinSide = pinSide

        super.init()

        backColor = .lightGray
        addLayoutGuide(contentBounds)
    }

    private func recreateConstraints() {
        guard let superview = superview else {
            return
        }

        var contentInset: UIEdgeInsets = .zero

        switch pinSide {
        case .left:
            contentInset.right = _lipSize
            layout.makeConstraints { make in
                (make.left, make.top, make.bottom) == superview
                make.right <= superview
            }

        case .top:
            contentInset.bottom = _lipSize
            layout.makeConstraints { make in
                (make.top, make.left, make.right) == superview
                make.bottom <= superview
            }

        case .right:
            contentInset.left = _lipSize
            layout.makeConstraints { make in
                (make.right, make.top, make.bottom) == superview
                make.left >= superview
            }

        case .bottom:
            contentInset.top = _lipSize
            layout.makeConstraints { make in
                (make.bottom, make.left, make.right) == superview
                make.bottom >= superview
            }
        }

        contentBounds.layout.remakeConstraints { make in
            make.edges.equalTo(self, inset: contentInset)
        }
    }

    override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        switch event.newValue {
        case .highlighted, .selected:
            backColor = .lightGray.faded(towards: .white, factor: 0.5)
        default:
            backColor = .lightGray
        }
    }

    override func superviewDidChange(_ newSuperview: View?) {
        super.superviewDidChange(newSuperview)

        recreateConstraints()
    }

    override func onMouseEnter() {
        super.onMouseEnter()

        switch pinSide {
        case .left, .right:
            controlSystem?.setMouseCursor(.resizeLeftRight)
        case .top, .bottom:
            controlSystem?.setMouseCursor(.resizeUpDown)
        }
    }

    override func onMouseLeave() {
        super.onMouseLeave()

        controlSystem?.setMouseCursor(.arrow)
    }

    override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        _mouseDown = true
        
        switch pinSide {
        case .left:
            _mouseOffset = event.location.x - bounds.width
        case .top:
            _mouseOffset = event.location.y - bounds.height
        case .right:
            _mouseOffset = event.location.x
        case .bottom:
            _mouseOffset = event.location.y
        }
    }

    override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)

        if _mouseDown {
            let mousePoint = convert(point: event.location, to: nil)

            switch pinSide {
            case .left:
                length = mousePoint.x - _mouseOffset
            case .top:
                length = mousePoint.y - _mouseOffset
            case .right:
                length = mousePoint.x - _mouseOffset
            case .bottom:
                length = mousePoint.y - _mouseOffset
            }
        }
    }

    override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        _mouseDown = false
    }

    /// The side of the container view this side panel should attach to.
    enum PinSide {
        case left
        case top
        case right
        case bottom
    }
}
