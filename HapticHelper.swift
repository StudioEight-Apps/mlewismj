import UIKit
import SwiftUI

// Create this as a new file: HapticHelper.swift
struct HapticHelper {
    static func lightTap() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    static func mediumTap() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    static func heavyTap() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
}

// Then in ANY button action, just call:
// HapticHelper.lightTap()
