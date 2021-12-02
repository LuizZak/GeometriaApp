import Foundation
import ImagineUI
import SwiftBlend2D

class StatusLabelsComponent: RaytracerUIComponent {
    private var _timeStarted: TimeInterval = 0.0
    private var _timeEnded: TimeInterval = 0.0
    private var _mouseLocation: BLPointI = .zero

    private var leftPadding: Double

    private let topLeftLabels: StackView = StackView(orientation: .vertical)
    private let batcherLabel: LabelControl = LabelControl()
    private let stateLabel: LabelControl = LabelControl()
    private let progressLabel: LabelControl = LabelControl()
    private let totalTimeLabel: LabelControl = LabelControl()
    
    private let bottomLeftLabels: StackView = StackView(orientation: .vertical)
    private let instructionsLabel: LabelControl = LabelControl(text: "R = Reset  |   Space = Pause")
    
    private let mouseLocationLabel: LabelControl = LabelControl()

    private weak var rendererCoordinator: RendererCoordinator?

    weak var delegate: RaytracerUIComponentDelegate?

    init(leftPadding: Double) {
        self.leftPadding = leftPadding
    }

    func setup(container: View) {
        topLeftLabels.location = .init(x: leftPadding + 5, y: 5)
        topLeftLabels.spacing = 5
        topLeftLabels.areaIntoConstraintsMask = [.location]
        bottomLeftLabels.areaIntoConstraintsMask = []
        bottomLeftLabels.spacing = 5
        container.addSubview(bottomLeftLabels)
        container.addSubview(topLeftLabels)
        
        topLeftLabels.addArrangedSubview(stateLabel)
        topLeftLabels.addArrangedSubview(batcherLabel)
        topLeftLabels.addArrangedSubview(progressLabel)
        topLeftLabels.addArrangedSubview(totalTimeLabel)
        
        bottomLeftLabels.addArrangedSubview(instructionsLabel)
        bottomLeftLabels.addArrangedSubview(mouseLocationLabel)
        
        bottomLeftLabels.layout.makeConstraints { make in
            make.left == leftPadding + 5
            make.bottom == container - 5
        }
        
        updateLabels()

        Scheduler.instance.fixedFrameEvent.addListener(owner: self) { [weak self] _ in
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

        coordinator?.stateDidChange.addListener(owner: self) { [weak self] (_, change) in
            DispatchQueue.main.async {
                self?.onStateChange(old: change.oldValue, new: change.newValue)
            }
        }

        if let coordinator = coordinator, coordinator.state == .running {
            updateLabels()
        }
        
        stateLabel.isVisible = coordinator != nil
        batcherLabel.isVisible = coordinator != nil
        progressLabel.isVisible = coordinator != nil
    }

    func rendererChanged<T: RendererType>(anyRenderer: T) {
        updateLabels()
    }

    func mouseMoved(event: MouseEventArgs) {
        _mouseLocation = BLPointI(x: Int32(event.location.x), y: Int32(event.location.y))
        mouseLocationLabel.text = "Mouse location: (x: \(_mouseLocation.x), y: \(_mouseLocation.y))"
    }
}
