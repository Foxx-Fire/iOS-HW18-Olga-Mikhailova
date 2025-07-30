//
//  ExtencionPomodoroViewcontroller.swift
//  iOS-HW18-Olga Mikhailova
//
//  Created by FoxxFire on 30.07.2025.
//

import UIKit

private extension PomodoroViewController {
    enum Constants {
        static let circleSize: CGFloat = 300
        static let circleLineWidth: CGFloat = 10
        static let labelHeight: CGFloat = 40
        static let buttonSize: CGFloat = 40
        static let buttonTopOffset: CGFloat = 55
        static let labelCenterOffset: CGFloat = -20
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
    }
    
    enum Images {
        static let play = UIImage(systemName: "play")
        static let pause = UIImage(systemName: "pause")
        static let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30)
    }
}
