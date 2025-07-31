//
//  ExtensionTimeInterval.swift
//  iOS-HW18-Olga Mikhailova
//
//  Created by FoxxFire on 31.07.2025.
//

import Foundation

extension TimeInterval {
    var mmssString: String {
        let totalSeconds = Int(self.rounded())
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
