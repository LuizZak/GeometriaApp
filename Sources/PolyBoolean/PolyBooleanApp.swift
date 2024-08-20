import Foundation
import ImagineUI
import SwiftBlend2D
import Geometria
import GeometriaClipping

open class PolyBooleanApp: ImagineUIWindowContent {
    var _updateTimer: SchedulerTimerType?
    var _lastRender: TimeInterval = UISettings.timeInSeconds()
    var _mouseLocation: UIPoint = .zero

    var scene: PolyBooleanScene = CapsuleSegmentsScene()

    var isShiftHeld: Bool = false

    open override func initialize() {
        super.initialize()

        _updateTimer = Scheduler.instance.scheduleTimer(interval: 1 / 60.0, repeats: true) { [weak self] in
            self?.update(UISettings.timeInSeconds())
        }

        Scheduler.instance.fixedFrameEvent.addListener(weakOwner: self) { [weak self] delta in
            self?.fixedFrameUpdate(delta)
        }

        scene.initialize(size: size)
    }

    open func fixedFrameUpdate(_ interval: TimeInterval) {
        let increment: Double
        if isShiftHeld {
            increment = interval / 10
        } else {
            increment = interval
        }

        scene.update(increment)
        invalidateScreen()
    }

    open override func mouseMoved(event: MouseEventArgs) {
        super.mouseMoved(event: event)

        scene.mouseMove(event)
    }

    open override func mouseDown(event: MouseEventArgs) {
        super.mouseDown(event: event)

        _mouseLocation = event.location
        scene.mouseDown(event)
    }

    open override func mouseUp(event: MouseEventArgs) {
        super.mouseUp(event: event)

        scene.mouseUp(event)
    }

    open override func keyDown(event: KeyEventArgs) {
        super.keyDown(event: event)

        guard !event.handled else {
            return
        }

        if event.keyCode == .r {
            scene.initialize(size: size)
        }
        if event.keyCode == .shiftKey {
            isShiftHeld = true
        }
    }

    open override func keyUp(event: KeyEventArgs) {
        super.keyUp(event: event)

        guard !event.handled else {
            return
        }

        if event.keyCode == .shiftKey {
            isShiftHeld = false
        }
    }

    open override func render(renderer: any Renderer, renderScale: UIVector, clipRegion: any ClipRegionType) {
        super.render(renderer: renderer, renderScale: renderScale, clipRegion: clipRegion)

        scene.render(in: renderer, clipRegion: clipRegion)

        renderLabels(renderer: renderer, clipRegion: clipRegion)
    }

    func renderLabels(renderer: any Renderer, clipRegion: any ClipRegionType) {
        renderer.setFill(.black)

        let delta = UISettings.timeInSeconds() - _lastRender
        _lastRender = UISettings.timeInSeconds()

        let mouseLocationText = TextLayout(
            font: Fonts.defaultFont(size: 20),
            text: "Mouse location: (\(_mouseLocation.x), \(_mouseLocation.y))"
        )
        renderer.fillTextLayout(mouseLocationText, at: .init(x: 5, y: 5))

        let delayText = TextLayout(font: Fonts.defaultFont(size: 20), text: "Delay: \(delta * 1000)ms")
        renderer.fillTextLayout(delayText, at: .init(x: 5, y: mouseLocationText.size.height + 5))
    }
}
