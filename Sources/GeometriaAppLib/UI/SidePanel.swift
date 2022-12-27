import ImagineUI
import Geometry
import Foundation

public class SidePanel: ControlView {
    private let _lipSize: Double = 4.0
    private var _mouseDown: Bool = false
    private var _mouseOffset: Double = 0.0

    // TODO: Make double clicking be handled by `DefaultControlSystem`.
    private var _lastMouseDown: TimeInterval = 0
    private var _lastMouseDownPoint: UIVector = .zero

    private var isMouseOverLip: Bool = false {
        didSet {
            guard isMouseOverLip != oldValue else { return }

            if isMouseOverLip {
                isHighlighted = true

                switch pinSide {
                case .left, .right:
                    controlSystem?.setMouseCursor(.resizeLeftRight)
                case .top, .bottom:
                    controlSystem?.setMouseCursor(.resizeUpDown)
                }
            } else {
                isHighlighted = false

                controlSystem?.setMouseCursor(.arrow)
            }
        }
    }
    
    /// The bounds that contents of this side panel should occupy in order to
    /// fit the draggable side panel handle area.
    public let contentBounds: LayoutGuide = LayoutGuide()

    /// The length of the panel on its superview.
    public var length: Double {
        didSet {
            length = max(_lipSize, length)

            guard length != oldValue else { return }

            setNeedsLayout()
        }
    }

    /// The side of the superview this side panel will pin to.
    public var pinSide: PinSide {
        didSet {
            guard pinSide != oldValue else { return }

            recreateConstraints()
        }
    }

    /// If `true`, enable collapsing of panel with a double click.
    public var allowCollapsingOnDoubleClick: Bool = true

    public override var intrinsicSize: UISize? {
        switch pinSide {
        case .left, .right:
            return UISize(width: length, height: 0)
        case .top, .bottom:
            return UISize(width: 0, height: length)
        }
    }

    public init(pinSide: PinSide, length: Double) {
        self.length = length
        self.pinSide = pinSide

        super.init()

        mouseOverHighlight = false
        clipToBounds = false
        backColor = .lightGray
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addLayoutGuide(contentBounds)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        recreateConstraints()
    }

    private func recreateConstraints() {
        guard let superview = superview else {
            return
        }

        let lipSize = _lipSize
        var contentInset: UIEdgeInsets = .zero

        switch pinSide {
        case .left:
            contentInset.right = lipSize

            layout.remakeConstraints { make in
                (make.left, make.top, make.bottom) == superview
                make.right <= superview
            }

        case .top:
            contentInset.bottom = lipSize

            layout.remakeConstraints { make in
                (make.top, make.left, make.right) == superview
                make.bottom <= superview
            }

        case .right:
            contentInset.left = lipSize

            layout.remakeConstraints { make in
                (make.right, make.top, make.bottom) == superview
                make.left >= superview
            }

        case .bottom:
            contentInset.top = lipSize

            layout.remakeConstraints { make in
                (make.bottom, make.left, make.right) == superview
                make.bottom >= superview
            }
        }

        contentBounds.layout.remakeConstraints { make in
            make.edges.equalTo(self, inset: contentInset)
        }
    }

    public override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        invalidate(bounds: lipArea())
    }

    public override func superviewDidChange(_ newSuperview: View?) {
        super.superviewDidChange(newSuperview)

        recreateConstraints()
    }

    public override func onMouseLeave() {
        super.onMouseLeave()

        isMouseOverLip = false
    }

    public override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        if isMouseOverLip {
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
    }

    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)

        if _mouseDown {
            let mouseOnSuperview = convert(point: event.location, to: superview)

            mouseDragLip(mouseOnSuperview: mouseOnSuperview)
        } else {
            isMouseOverLip = isInLipArea(event.location)
        }
    }

    public override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        _mouseDown = false
    }

    public override func onMouseClick(_ event: MouseEventArgs) {
        super.onMouseClick(event)

        if isMouseOverLip {
            if _lastMouseDownPoint.distance(to: event.location) < 10 && UISettings.timeInSeconds() - _lastMouseDown < 1 {
                _mouseDown = false
                length = 0.0

                _lastMouseDown = 0.0
            } else {
                _lastMouseDownPoint = event.location
                _lastMouseDown = UISettings.timeInSeconds()
            }
        }
    }

    public override func renderBackground(in renderer: Renderer, screenRegion: ClipRegionType) {
        super.renderBackground(in: renderer, screenRegion: screenRegion)

        renderLipArea(in: renderer, screenRegion: screenRegion)
    }

    func renderLipArea(in renderer: Renderer, screenRegion: ClipRegionType) {
        let lipRect = lipArea()

        if isHighlighted {
            renderer.setFill(.cornflowerBlue)
        } else {
            renderer.setFill(.lightGray.faded(towards: .black, factor: 0.15))
        }

        renderer.fill(lipRect)
    }

    func mouseDragLip(mouseOnSuperview: UIPoint) {
        guard let superview = superview else {
            return
        }
        
        switch pinSide {
        case .left:
            length = min(superview.size.width, mouseOnSuperview.x - _mouseOffset)
        case .top:
            length = min(superview.size.height, mouseOnSuperview.y - _mouseOffset)

        case .right:
            length = min(superview.size.width, superview.size.width - (mouseOnSuperview.x - _mouseOffset))
        case .bottom:
            length = min(superview.size.height, superview.size.height - (mouseOnSuperview.y - _mouseOffset))
        }
    }

    func isInLipArea(_ point: UIPoint) -> Bool {
        return lipArea().contains(point)
    }

    /// Bounds in this side panel that the draggable lip is placed.
    /// Depends on `_lipSize` and `pinSide`.
    func lipArea() -> UIRectangle {
        var area = bounds

        switch pinSide {
        case .left:
            area = area.stretchingLeft(to: area.right - _lipSize)

        case .top:
            area = area.stretchingTop(to: area.bottom - _lipSize)

        case .right:
            area = area.stretchingRight(to: area.left + _lipSize)

        case .bottom:
            area = area.stretchingBottom(to: area.top + _lipSize)
        }

        return area
    }

    /// The side of the container view this side panel should attach to.
    public enum PinSide {
        case left
        case top
        case right
        case bottom
    }
}
