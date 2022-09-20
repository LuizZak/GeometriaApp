import Foundation
import ImagineUI

class StatusMessageStackComponent: RaytracerUIComponent {
    private let label = LabelControl(text: "")
    private var lastAnim: EventListenerKey?

    weak var delegate: RaytracerUIComponentDelegate?

    func setup(container: View) {
        container.addSubview(label)

        label.layout.makeConstraints { make in
            make.bottom == container - 5
            make.right == container - 5
        }

        label.alpha = 0.0
    }

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {

    }

    func rendererChanged<T: RendererType>(anyRenderer: T) {

    }

    func mouseMoved(event: MouseEventArgs) {

    }

    // MARK: -

    public func showMessage(_ message: String) {
        lastAnim?.removeListener()

        label.text = message
        label.alpha = 1.0

        lastAnim = Animation.interpolate(
            from: 1.0,
            to: 0.0,
            duration: 2.0,
            delay: 5.0
        ) { [weak label] alpha in
        
            label?.alpha = alpha
        }
    }
}

private class Animation {
    private static let owner = _AnimationOwner()

    /// Register a block for UI-time, fixed-frame interval animation.
    ///
    /// - precondition: `duration > 0`
    @discardableResult
    static func interpolate(
        from start: Double,
        to end: Double,
        duration: TimeInterval,
        delay: TimeInterval = 0,
        animation: @escaping (Double) -> Void
    ) -> EventListenerKey {

        precondition(duration > 0)

        var didStart = false
        var startTime: TimeInterval?
        var key: EventListenerKey?

        let nKey = Scheduler
            .instance
            .fixedFrameEvent
            .addListener(weakOwner: owner) { _ in
                let timeInSeconds = UISettings.timeInSeconds()

                guard let startTime = startTime else {
                    startTime = timeInSeconds
                    return
                }

                let elapsed = timeInSeconds - (startTime + delay)
                guard elapsed >= 0 else {
                    return
                }

                // Do a single tick at the start of the animation
                if !didStart {
                    didStart = true
                    animation(start)
                    return
                }

                if elapsed >= duration {
                    animation(end)

                    key?.removeListener()
                } else {
                    let t = elapsed / duration

                    let interp = start + (end - start) * t

                    animation(interp)
                }
            }
        
        key = nKey

        return nKey
    }

    private class _AnimationOwner {

    }
}
