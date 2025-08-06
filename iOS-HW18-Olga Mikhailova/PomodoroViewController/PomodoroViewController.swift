import UIKit

final class PomodoroViewController: UIViewController {
    
    private let circleView = PomodoroCircleView()
    
    // MARK: - Timer Properties
    
    private var isWorkMode = true
    private var isRunning = false
    private var timer: Timer?
    private var currentTime: TimeInterval = 0
    private var startDate: Date?
    private var isTransitioning = false
    
    // MARK: - Helper Properties
    
    private var currentDuration: TimeInterval {
        isWorkMode ? Time.workDuration : Time.restDuration
    }
    
    private var currentStrokeColor: CGColor {
        isWorkMode ? Colors.work.cgColor : Colors.rest.cgColor
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupHierarchy()
        setupLayout()
        resetToInitialState()
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        view.backgroundColor = .white
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.playStopButton.addAction(
            UIAction { [weak self] _ in
                self?.buttonTapped()
            },
            for: .touchUpInside
        )
    }
    
    private func setupHierarchy() {
        view.addSubview(circleView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: Constants.circleSize)
        ])
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
        guard !isTransitioning else { return }
        isTransitioning = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isTransitioning = false
        }
        
        isRunning ? pauseTimer() : startTimer()
    }
}

extension PomodoroViewController {
    enum Constants {
        static let circleSize: CGFloat = 300
        static let circleLineWidth: CGFloat = 10
        static let labelHeight: CGFloat = 40
        static let buttonSize: CGFloat = 40
        static let buttonTopOffset: CGFloat = 55
        static let labelCenterOffset: CGFloat = -20
        static let circleInset: CGFloat = 20
    }
    
    enum Time {
        static let workDuration: TimeInterval = 6
        static let restDuration: TimeInterval = 3
        static let timerInterval: TimeInterval = 0.05
        static let colorTransitionDuration: TimeInterval = 0.3
    }
    
    enum Colors {
        static let work = UIColor.red
        static let rest = UIColor.green
        static let background = UIColor.systemGray5
        static let circleBackground = UIColor.systemGray4
    }
    
    enum Images {
        static let play = UIImage(systemName: "play")
        static let pause = UIImage(systemName: "pause")
        static let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    }
}

