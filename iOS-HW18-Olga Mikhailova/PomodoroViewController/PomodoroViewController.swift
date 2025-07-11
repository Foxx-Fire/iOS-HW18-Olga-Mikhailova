import UIKit

final class PomodoroViewController: UIViewController {
  
  // MARK: - UI
  
  private lazy var circleView: UIView = {
    let circle = UIView()
    circle.backgroundColor = .systemGray5
    circle.layer.cornerRadius = 150
    circle.layer.borderWidth = 10
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
    button.setImage(UIImage(systemName: "play"), for: .normal)
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
    
    setupView()
    setupHierarchy()
    setupLayout()
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
      timeLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: -20),
      
      playStopButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 55),
      playStopButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
      playStopButton.heightAnchor.constraint(equalToConstant: 40),
      playStopButton.widthAnchor.constraint(equalToConstant: 40)
    ])
  }
  
  // MARK: - Actions
  
  @objc private func buttonTapped() {
      print("Button tapped")
      // Здесь будет логика старта/паузы таймера
  }
}
