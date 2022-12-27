import Foundation
import ImagineUI
import SwiftBlend2D

class StatusLabelsComponent: RaytracerUIComponent {
    private var _timeStarted: TimeInterval = 0.0
    private var _timeEnded: TimeInterval = 0.0
    private var _mouseLocation: BLPointI = .zero

    private let topLeftLabels: StackView = StackView(orientation: .vertical)

    private let totalTimeLabel: LabelControl = LabelControl()
    // Next three only visible while a rendering coordinator is active
    private let stateLabel: LabelControl = LabelControl()
    private let batcherLabel: LabelControl = LabelControl()
    private let progressLabel: LabelControl = LabelControl()

    
    private let topRightLabels: StackView = StackView(orientation: .vertical)

    private let resolutionLabel: LabelControl = LabelControl(text: "<viewport resolution unknown>")
    private let dpiScalingModeLabel: LabelControl = LabelControl(text: "<DPI scaling mode unknown>")


    private let bottomLeftLabels: StackView = StackView(orientation: .vertical)

    private let instructionsLabel: LabelControl = LabelControl()
    private let mouseLocationLabel: LabelControl = LabelControl()

    private weak var rendererCoordinator: RendererCoordinator?

    weak var delegate: RaytracerUIComponentDelegate?

    func setup(container: View) {
        instructionsLabel.text = [
            "R = Reset",
            "S = Toggle DPI scaling",
            "Space = Pause",
            "O = Debug print Processing scene @ mouse over pixel",
        ].joined(separator: "   |   ")

        container.addSubview(topLeftLabels)
        container.addSubview(topRightLabels)
        container.addSubview(bottomLeftLabels)

        topLeftLabels.spacing = 5
        topLeftLabels.addArrangedSubview(stateLabel)
        topLeftLabels.addArrangedSubview(batcherLabel)
        topLeftLabels.addArrangedSubview(progressLabel)
        topLeftLabels.addArrangedSubview(totalTimeLabel)

        topRightLabels.spacing = 5
        topRightLabels.alignment = .trailing
        topRightLabels.addArrangedSubview(resolutionLabel)
        topRightLabels.addArrangedSubview(dpiScalingModeLabel)
        
        bottomLeftLabels.spacing = 5
        bottomLeftLabels.addArrangedSubview(instructionsLabel)
        bottomLeftLabels.addArrangedSubview(mouseLocationLabel)
        
        topLeftLabels.layout.makeConstraints { make in
            make.left == container + 5
            make.top == container + 5
        }

        topRightLabels.layout.makeConstraints { make in
            make.right == container - 5
            make.top == container + 5
        }

        bottomLeftLabels.layout.makeConstraints { make in
            make.left == container + 5
            make.bottom == container - 5
        }
        
        updateLabels()

        Scheduler.instance.fixedFrameEvent.addListener(weakOwner: self) { [weak self] _ in
            guard let self = self else { return }

            if let renderer = self.rendererCoordinator, renderer.state == .running {
                self.updateLabels()
            }
        }
    }
    
    func updateLabels() {
        if let coordinator = rendererCoordinator {
            stateLabel.text = "State: \(coordinator.state.description)"
            batcherLabel.text = "Pixel order mode: \(coordinator.batcher.displayName)"
            progressLabel.text = "Progress of pixel batches served: \(String(format: "%.2lf", coordinator.progress * 100))%"

            resolutionLabel.text = "\(coordinator.viewportSize.width)x\(coordinator.viewportSize.height)"
        }
        
        if _timeStarted != 0.0 {
            if _timeEnded != 0.0 {
                let timeString = String(format: "%.3lf", _timeEnded - _timeStarted)
                
                totalTimeLabel.text = "Total time (s): \(timeString)"
            } else {
                totalTimeLabel.text = "Total time (s): Running..."
            }
        } else {
            totalTimeLabel.text = "Total time (s): No run"
        }
    }

    func onStateChange(old: RendererCoordinator.State, new: RendererCoordinator.State) {
        if old == .unstarted || old == .cancelled || old == .finished {
            if new == .running {
                self._timeStarted = UISettings.timeInSeconds()
            }
        }
        if new == .finished {
            self._timeEnded = UISettings.timeInSeconds()
        }
        
        self.updateLabels()
    }

    func rendererCoordinatorChanged(_ coordinator: RendererCoordinator?) {
        self.rendererCoordinator = coordinator

        self._timeEnded = 0.0
        self._timeStarted = 0.0

        coordinator?.stateDidChange.addListener(weakOwner: self) { [weak self] (change) in
            DispatchQueue.main.async {
                self?.onStateChange(old: change.oldValue, new: change.newValue)
            }
        }
        
        updateLabels()
        
        stateLabel.isVisible = coordinator != nil
        batcherLabel.isVisible = coordinator != nil
        progressLabel.isVisible = coordinator != nil
    }

    func rendererChanged<T: RendererType>(anyRenderer: T) {
        updateLabels()
    }

    func mouseMoved(event: MouseEventArgs) {
        _mouseLocation = event.location.asBLPointI
        mouseLocationLabel.text = "Mouse location: (x: \(_mouseLocation.x), y: \(_mouseLocation.y))"
    }

    func updateDpiScalingModeLabel(_ mode: RaytracerApp.DpiScalingMode, currentScale: Double) {
        switch mode {
        case .ignoreDpi:
            dpiScalingModeLabel.text = "Ignoring DPI scaling (currently \(String(format: "%.2f", currentScale)))"
        case .useDpiScale:
            dpiScalingModeLabel.text = "Using DPI scaling (currently \(String(format: "%.2f", currentScale)))"
        }
    }
}
