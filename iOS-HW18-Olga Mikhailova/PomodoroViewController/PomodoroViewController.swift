import UIKit

final class PomodoroViewController: UIViewController {
    
    private let circleView = PomodoroCircleView()
    
    // MARK: - Timer Properties
    
    private var isWorkMode = true
    private var isRunning = false
    private var timer: Timer?
    private var currentTime: TimeInterval = 0
    private var startDate: Date?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
        resetToInitialState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCircleView()
    }
    
    // MARK: - Setups
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupHierarchy() {
        view.addSubview(circleView)
        circleView.playStopButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: Constants.circleSize)
        ])
    }
    
    private func setupCircleView() {
        circleView.layer.cornerRadius = Constants.circleSize / 2
    }

    // MARK: - Helper Properties
    
    private var currentDuration: TimeInterval {
        isWorkMode ? Time.workDuration : Time.restDuration
    }
    
    private var currentStrokeColor: CGColor {
        isWorkMode ? Colors.work.cgColor : Colors.rest.cgColor
    }
    
    // MARK: - Timer Control
    
    private func startTimer() {
        timer?.invalidate()
        
        if circleView.progressLayer.speed == 0 {
            resumeAnimation()
        } else {
            startProgressAnimation()
        }
        
        startDate = Date().addingTimeInterval(-currentTime)
        timer = Timer.scheduledTimer(
            timeInterval: Time.timerInterval,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
        
        isRunning = true
        updateButtonImage(to: Images.pause)
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        
        if let startDate = startDate {
            currentTime = Date().timeIntervalSince(startDate)
        }
        
        pauseAnimation()
        isRunning = false
        updateButtonImage(to: Images.play)
    }
    
    private func resetToInitialState() {
        pauseTimer()
        isWorkMode = true
        isRunning = false
        currentTime = 0
        startDate = nil
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circleView.progressLayer.strokeEnd = 1.0
        circleView.progressLayer.strokeColor = currentStrokeColor
        circleView.progressLayer.speed = 1.0
        circleView.progressLayer.timeOffset = 0.0
        circleView.progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        updateUIForCurrentPhase()
        circleView.timeLabel.text = Time.workDuration.mmssString
    }
    
    // MARK: - Animation
    
    private func startProgressAnimation() {
        let fromValue = 1.0 - (currentTime / currentDuration)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circleView.progressLayer.strokeEnd = fromValue
        circleView.progressLayer.strokeColor = currentStrokeColor
        circleView.progressLayer.speed = 1.0
        circleView.progressLayer.timeOffset = 0.0
        circleView.progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = 0.0
        animation.duration = currentDuration - currentTime
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        circleView.progressLayer.add(animation, forKey: "progressAnimation")
    }
    
    private func pauseAnimation() {
        let pausedTime = circleView.progressLayer.convertTime(CACurrentMediaTime(), from: nil)
        circleView.progressLayer.speed = 0.0
        circleView.progressLayer.timeOffset = pausedTime
    }
    
    private func resumeAnimation() {
        let pausedTime = circleView.progressLayer.timeOffset
        circleView.progressLayer.speed = 1.0
        circleView.progressLayer.timeOffset = 0.0
        circleView.progressLayer.beginTime = 0.0
        let timeSincePause = circleView.progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        circleView.progressLayer.beginTime = timeSincePause
    }
    
    // MARK: - UI Updates
    
    private func updateUIForCurrentPhase() {
        circleView.timeLabel.textColor = isWorkMode ? Colors.work : Colors.rest
        circleView.playStopButton.tintColor = isWorkMode ? Colors.work : Colors.rest
    }
    
    private func updateButtonImage(to image: UIImage?) {
        circleView.playStopButton.setImage(image, for: .normal)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval.rounded())
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
    
    // MARK: - Timer Updates
    
    @objc private func updateTimer() {
        guard let startDate = startDate else { return }
        
        currentTime = Date().timeIntervalSince(startDate)
        
        if currentTime >= currentDuration {
            timer?.invalidate()
            switchPhase()
            return
        }
        
        updateTimeDisplay()
    }
    
    private func updateTimeDisplay() {
        let remaining = max(0.0, currentDuration - currentTime)
        circleView.timeLabel.text = timeString(from: remaining)
    }
    
    private func switchPhase() {
        circleView.progressLayer.removeAllAnimations()
        isWorkMode.toggle()
        currentTime = 0
        startDate = Date()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circleView.progressLayer.strokeEnd = 1.0
        circleView.progressLayer.strokeColor = currentStrokeColor
        circleView.progressLayer.speed = 1.0
        circleView.progressLayer.timeOffset = 0.0
        circleView.progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        UIView.animate(withDuration: Time.colorTransitionDuration) {
            self.updateUIForCurrentPhase()
        }
        
        if isRunning {
            startTimer()
        } else {
            updateTimeDisplay()
        }
    }
    
    @objc private func buttonTapped() {
        isRunning ? pauseTimer() : startTimer()
    }
}
