import SwiftUI

struct AppTheme {
    
    // MARK: - Gradient Background
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "#0B1C35"), // Deep navy top
            Color(hex: "#1B2B4B")  // Slightly lighter navy bottom
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Font Helpers
    static func serifTitle(size: CGFloat) -> Font {
        Font.custom("Georgia-Bold", size: size) // Replace with custom name if you add one
    }

    static func serifBody(size: CGFloat) -> Font {
        Font.custom("Georgia", size: size)
    }

    // MARK: - Colors
    static let surface = Color(hex: "#16203B")        // For cards, textboxes
    static let accent = Color(hex: "#4F6FE8")          // For interactive elements
    static let textPrimary = Color.white               // Main text
    static let textSecondary = Color.gray              // Subtext
}

