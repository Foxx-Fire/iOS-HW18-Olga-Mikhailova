import UIKit

final class PomodoroViewController: UIViewController {
    
    // MARK: - Timer Properties
    
    private var isWorkTime = true
    private var isStarted = false
    private var timer: Timer?
    private let workDuration: TimeInterval = 6
    private let restDuration: TimeInterval = 3
    private var currentTime: TimeInterval = 0
    private var startDate: Date?
    
    // ProgressBar
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    // MARK: - UI
    
    private lazy var circleView: UIView = {
        let circle = UIView()
        circle.backgroundColor = .systemGray4
        circle.translatesAutoresizingMaskIntoConstraints = false
        return circle
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "06:00"
        label.textColor = .red
        label.font = .systemFont(ofSize: 45, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var playStopButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        button.setImage(UIImage(systemName: "play", withConfiguration: config),
                       for: .normal)
        button.tintColor = .red
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(buttonTapped),
                        for: .touchUpInside)
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
        circleView.layer.cornerRadius = circleView.bounds.width / 2
        setupCircleLayers()
    }
    
    // MARK: - Setups
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupHierarchy() {
        view.addSubview(circleView)
        circleView.addSubview(timeLabel)
        circleView.addSubview(playStopButton)
        circleView.layer.addSublayer(backgroundLayer)
        circleView.layer.addSublayer(progressLayer)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 300),
            circleView.heightAnchor.constraint(equalToConstant: 300),
            
            timeLabel.heightAnchor.constraint(equalToConstant: 40),
            timeLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor,
                                              constant: -20),
            
            playStopButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor,
                                               constant: 55),
            playStopButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            playStopButton.heightAnchor.constraint(equalToConstant: 40),
            playStopButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Setup Circle
    
    private func setupCircleLayers() {
        let center = CGPoint(x: circleView.bounds.width/2,
                            y: circleView.bounds.height/2)
        let radius = min(circleView.bounds.width, circleView.bounds.height)/2 - 20
        
        let backgroundPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.lineCap = .round
        
        let progressPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 3 * .pi/2,
            endAngle: -.pi/2,
            clockwise: false
        )
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = isWorkTime ? UIColor.red.cgColor : UIColor.green.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1.0
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
            timeInterval: 0.05,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer!, forMode: .common)
        
        isStarted = true
        playStopButton.setImage(UIImage(systemName: "pause"), for: .normal)
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        
        if let startDate = startDate {
            currentTime = Date().timeIntervalSince(startDate)
        }
        
        pauseAnimation()
        isStarted = false
        playStopButton.setImage(UIImage(systemName: "play"), for: .normal)
    }
    
    private func resetToInitialState() {
        pauseTimer()
        isWorkTime = true
        isStarted = false
        currentTime = 0
        startDate = nil
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 1.0
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        timeLabel.textColor = .red
        playStopButton.tintColor = .red
        playStopButton.setImage(UIImage(systemName: "play"), for: .normal)
        timeLabel.text = "06:00"
    }
    
    // MARK: - Animation
    
    private func startProgressAnimation() {
        let duration = isWorkTime ? workDuration : restDuration
        let fromValue = 1.0 - (currentTime / duration)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = fromValue
        progressLayer.strokeColor = isWorkTime ? UIColor.red.cgColor : UIColor.green.cgColor
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = 0.0
        animation.duration = duration - currentTime
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
    
    @objc private func updateTimer() {
        guard let startDate = startDate else { return }
        
        currentTime = Date().timeIntervalSince(startDate)
        let duration = isWorkTime ? workDuration : restDuration
        
        if currentTime >= duration {
            timer?.invalidate()
            switchPhase()
            return
        }
        
        updateTimeDisplay()
    }
    
    private func updateTimeDisplay() {
        let duration = isWorkTime ? workDuration : restDuration
        let remaining = max(0.0, duration - currentTime)
        let totalSeconds = Int(remaining.rounded())
        timeLabel.text = String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
    
    private func switchPhase() {
        progressLayer.removeAllAnimations()
        isWorkTime.toggle()
        currentTime = 0
        startDate = Date()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 1.0
        progressLayer.strokeColor = isWorkTime ? UIColor.red.cgColor : UIColor.green.cgColor
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        CATransaction.commit()
        
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.textColor = self.isWorkTime ? .red : .green
            self.playStopButton.tintColor = self.isWorkTime ? .red : .green
        }
        
        if isStarted {
            startTimer()
        } else {
            updateTimeDisplay()
        }
    }
    
    @objc private func buttonTapped() {
        if isStarted {
            pauseTimer()
        } else {
            startTimer()
        }
    }
}
