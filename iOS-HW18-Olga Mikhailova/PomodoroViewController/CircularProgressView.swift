//
//  CircularProgressView.swift
//  iOS-HW18-Olga Mikhailova
//
//  Created by FoxxFire on 30.07.2025.
//

import UIKit

final class PomodoroCircleView: UIView {
    
    // MARK: - Layers
    let progressLayer = CAShapeLayer()
    let backgroundLayer = CAShapeLayer()
    
    // MARK: - UI Elements
    let timeLabel = UILabel()
    let playStopButton = UIButton(type: .system)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = PomodoroViewController.Colors.circleBackground
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
        
        timeLabel.textColor = PomodoroViewController.Colors.work
        timeLabel.font = .systemFont(ofSize: 45, weight: .medium)
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        playStopButton.setImage(
            PomodoroViewController.Images.play?.withConfiguration(
                PomodoroViewController.Images.symbolConfig
            ),
            for: .normal
        )
        playStopButton.tintColor = PomodoroViewController.Colors.work
        playStopButton.contentVerticalAlignment = .fill
        playStopButton.contentHorizontalAlignment = .fill
        playStopButton.imageView?.contentMode = .scaleAspectFit
        playStopButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(timeLabel)
        addSubview(playStopButton)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        setupCircleLayers()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            timeLabel.heightAnchor.constraint(
                equalToConstant: PomodoroViewController.Constants.labelHeight
            ),
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor,
                constant: PomodoroViewController.Constants.labelCenterOffset
            ),
            
            playStopButton.topAnchor.constraint(
                equalTo: timeLabel.bottomAnchor,
                constant: PomodoroViewController.Constants.buttonTopOffset
            ),
            playStopButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playStopButton.heightAnchor.constraint(
                equalToConstant: PomodoroViewController.Constants.buttonSize
            ),
            playStopButton.widthAnchor.constraint(
                equalToConstant: PomodoroViewController.Constants.buttonSize
            )
        ])
    }
    
    // MARK: - Circle Drawing
    
    private func setupCircleLayers() {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = bounds.width / 2 - PomodoroViewController.Constants.circleInset
        
        let backgroundPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.strokeColor = PomodoroViewController.Colors.background.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = PomodoroViewController.Constants.circleLineWidth
        backgroundLayer.lineCap = .round
        
        let progressPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 3 * .pi / 2,
            endAngle: -.pi / 2,
            clockwise: false
        )
        progressLayer.path = progressPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = PomodoroViewController.Constants.circleLineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1.0
    }
}


