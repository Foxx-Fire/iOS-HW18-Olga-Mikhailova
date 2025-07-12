import UIKit

final class PomodoroViewController: UIViewController {
  
  // MARK: - Timer Properties
  
  private var isWorkTime = true
  private var isStarted = false
  private var timer: Timer?
  private let workDuration = 6
  private let restDuration = 3
  private var currentSeconds = 0
  
  // MARK: - UI
  
  private lazy var circleView: UIView = {
    let circle = UIView()
    circle.backgroundColor = .systemGray5
    circle.layer.borderWidth = 4
    circle.layer.borderColor = UIColor.darkGray.cgColor
    circle.translatesAutoresizingMaskIntoConstraints = false
    return circle
  }()
  
  //  private lazy var countingView: UIView = {
  //    let circle = UIView()
  //    circle.backgroundColor = .systemGray5
  //    circle.layer.cornerRadius = 10
  //    circle.layer.borderWidth = 3
  //    circle.layer.borderColor = UIColor.blue.cgColor
  //    circle.translatesAutoresizingMaskIntoConstraints = false
  //    return circle
  //  }()
  
  private lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.textColor = .red
    label.font = .systemFont(ofSize: 45, weight: .medium)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var playStopButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 30)
    button.setImage(UIImage(
      systemName: "play",
      withConfiguration: config),
                    for: .normal
    )
    button.tintColor = .red
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
    
    resetToInitialState()
    setupView()
    setupHierarchy()
    setupLayout()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    circleView.layer.cornerRadius = circleView.bounds.width / 2
  }
  
  // MARK: - Setups
  
  func setupView() {
    view.backgroundColor = .white
  }
  
  func setupHierarchy() {
    view.addSubview(circleView)
    //  view.addSubview(countingView)
    circleView.addSubview(timeLabel)
    circleView.addSubview(playStopButton)
  }
  
  func setupLayout() {
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
  
  // MARK: - Actions
  
  @objc private func buttonTapped() {
    let config = UIImage.SymbolConfiguration(pointSize: 30)
    
    if isStarted {
      pauseTimer()
      playStopButton.setImage(UIImage(
        systemName: "play",
        withConfiguration: config),
                              for: .normal
      )
    } else {
      startTimer()
      playStopButton.setImage(UIImage(
        systemName: "pause",
        withConfiguration: config),
                              for: .normal
      )
    }
    isStarted.toggle()
  }
  
  //MARK: - Functions
  
  private func startTimer() {
    timer = Timer.scheduledTimer(
      timeInterval: 1,
      target: self,
      selector: #selector(updateTimer),
      userInfo: nil,
      repeats: true
    )
  }
  
  private func pauseTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func resetToInitialState() {
    pauseTimer()
    isWorkTime = true
    isStarted = false
    currentSeconds = workDuration
    updateTimeDisplay(seconds: currentSeconds)
    
    switchToWorkColors()
    let config = UIImage.SymbolConfiguration(pointSize: 30)
    playStopButton.setImage(UIImage(systemName: "play", withConfiguration: config), for: .normal)
  }
  
  private func switchPhase() {
    isWorkTime.toggle()
    currentSeconds = isWorkTime ? workDuration : restDuration
    updateTimeDisplay(seconds: currentSeconds)
    
    if isWorkTime {
      switchToWorkColors()
    } else {
      switchToRestColors()
    }
  }
  
  @objc private func updateTimer() {
    currentSeconds -= 1
    updateTimeDisplay(seconds: currentSeconds)
    
    if currentSeconds <= 0 {
      switchPhase()
    }
  }
  
  // MARK: - UI Updates
  
  private func updateTimeDisplay(seconds: Int) {
    guard seconds >= 0 else { return }
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    timeLabel.text = String(format: "%02d:%02d", minutes, remainingSeconds)
  }
  
  private func switchToWorkColors() {
    UIView.animate(withDuration: 0.3) {
      self.circleView.layer.borderColor = UIColor.red.cgColor
      self.timeLabel.textColor = .red
      self.playStopButton.tintColor = .red
    }
  }
  
  private func switchToRestColors() {
    UIView.animate(withDuration: 0.3) {
      self.circleView.layer.borderColor = UIColor.green.cgColor
      self.timeLabel.textColor = .green
      self.playStopButton.tintColor = .green
    }
  }
}
