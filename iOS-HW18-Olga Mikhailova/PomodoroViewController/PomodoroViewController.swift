import UIKit

final class PomodoroViewController: UIViewController {
    
    // MARK: - Timer Properties
    
    private var isWorkMode = true
    private var isStarted = false
    private var timer: Timer?
    private var currentTime: TimeInterval = 0
    private var startDate: Date?
    
    // MARK: - UI
    
    private lazy var circleView: UIView = {
        let circle = UIView()
        circle.backgroundColor = Colors.circleBackground
        circle.translatesAutoresizingMaskIntoConstraints = false
        return circle
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = timeString(from: Time.workDuration)
        label.textColor = Colors.work
        label.font = .systemFont(ofSize: 45, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var playStopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Images.play?.withConfiguration(Images.symbolConfig), for: .normal)
        button.tintColor = Colors.work
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        setupCircleLayers()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupHierarchy() {
        view.addSubview(circleView)
        circleView.addSubview(timeLabel)
        circleView.addSubview(playStopButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: Constants.circleSize),
            
            timeLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            timeLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor,
                                               constant: Constants.labelCenterOffset),
            
            playStopButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor,
                                                constant: Constants.buttonTopOffset),
            playStopButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            playStopButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            playStopButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }
    
    private func setupCircleView() {
        circleView.layer.cornerRadius = Constants.circleSize / 2
    }
    
    private func setupCircleLayers() {
        let center = CGPoint(x: Constants.circleSize/2, y: Constants.circleSize/2)
        let radius = Constants.circleSize/2 - Constants.circleInset
        
        // Background Layer
        let backgroundPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.strokeColor = Colors.background.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = Constants.circleLineWidth
        backgroundLayer.lineCap = .round
        
        // Progress Layer
        let progressPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 3 * .pi/2,
            endAngle: -.pi/2,
            clockwise: false
        )
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = currentStrokeColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = Constants.circleLineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1.0
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
        
        if progressLayer.speed == 0 {
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
        RunLoop.main.add(timer!, forMode: .common)
        
        isStarted = true
        updateButtonImage(to: Images.pause)
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        
        if let startDate = startDate {
            currentTime = Date().timeIntervalSince(startDate)
        }
        
        pauseAnimation()
        isStarted = false
        updateButtonImage(to: Images.play)
    }
    
    private func resetToInitialState() {
        pauseTimer()
        isWorkMode = true
        isStarted = false
        currentTime = 0
        startDate = nil
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 1.0
        progressLayer.strokeColor = currentStrokeColor
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        updateUIForCurrentPhase()
        timeLabel.text = timeString(from: Time.workDuration)
    }
    
    // MARK: - Animation
    
    private func startProgressAnimation() {
        let fromValue = 1.0 - (currentTime / currentDuration)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = fromValue
        progressLayer.strokeColor = currentStrokeColor
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = 0.0
        animation.duration = currentDuration - currentTime
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        progressLayer.add(animation, forKey: "progressAnimation")
    }
    
    private func pauseAnimation() {
        let pausedTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressLayer.speed = 0.0
        progressLayer.timeOffset = pausedTime
    }
    
    private func resumeAnimation() {
        let pausedTime = progressLayer.timeOffset
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        let timeSincePause = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        progressLayer.beginTime = timeSincePause
    }
    
    // MARK: - UI Updates
    
    private func updateUIForCurrentPhase() {
        timeLabel.textColor = isWorkMode ? Colors.work : Colors.rest
        playStopButton.tintColor = isWorkMode ? Colors.work : Colors.rest
    }
    
    private func updateButtonImage(to image: UIImage?) {
        playStopButton.setImage(image, for: .normal)
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
        timeLabel.text = timeString(from: remaining)
    }
    
    private func switchPhase() {
        progressLayer.removeAllAnimations()
        isWorkMode.toggle()
        currentTime = 0
        startDate = Date()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 1.0
        progressLayer.strokeColor = currentStrokeColor
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        UIView.animate(withDuration: Time.colorTransitionDuration) {
            self.updateUIForCurrentPhase()
        }
        
        if isStarted {
            startTimer()
        } else {
            updateTimeDisplay()
        }
    }
    
    @objc private func buttonTapped() {
        isStarted ? pauseTimer() : startTimer()
    }
}

