import SwiftUI

// MARK: - Onboarding Theme
// Pixel-matched to Loveable prototype

struct OnboardingTheme {
    
    // MARK: - Colors (from Loveable index.css)
    
    /// Warm cream background - #F5EFE7
    static let background = Color(hex: "#F5EFE7")
    
    /// Near black foreground - #2C2C2C
    static let foreground = Color(hex: "#2C2C2C")
    
    /// Warm tan card background - #EDE6DC
    static let card = Color(hex: "#EDE6DC")
    
    /// Selected card state - #E0D6C8
    static let cardSelected = Color(hex: "#E0D6C8")
    
    /// Muted gold accent - #C4A574
    static let accent = Color(hex: "#C4A574")
    
    /// Warm gray for secondary text - #6B6159
    static let muted = Color(hex: "#6B6159")
    
    /// Progress bar track - slightly darker than background
    static let progressTrack = Color(hex: "#E8E0D5")
    
    /// White for button text on dark backgrounds
    static let buttonText = Color.white
    
    /// Black for Apple button - #1A1A1A
    static let buttonBlack = Color(hex: "#1A1A1A")

    /// Input field background - slightly darker than card for contrast
    static let inputBackground = Color(hex: "#E5DDD2")

    /// Input field border - subtle but visible
    static let inputBorder = Color(hex: "#D1C7B8")

    /// Placeholder text - readable against input background
    static let placeholder = Color(hex: "#8B8078")
    
    
    // MARK: - Typography
    
    /// Large headline - 28pt serif medium (Playfair Display equivalent)
    static func headlineLarge() -> Font {
        .system(size: 28, weight: .medium, design: .serif)
    }
    
    /// Standard headline - 24pt serif medium
    static func headline() -> Font {
        .system(size: 24, weight: .medium, design: .serif)
    }
    
    /// Body text - 15pt regular
    static func body() -> Font {
        .system(size: 15, weight: .regular)
    }
    
    /// Card text - 15pt regular
    static func cardText() -> Font {
        .system(size: 15, weight: .regular)
    }
    
    /// Quote text - 15pt regular (styled italic in use)
    static func quoteText() -> Font {
        .system(size: 15, weight: .regular)
    }
    
    /// Button text - 16pt medium
    static func button() -> Font {
        .system(size: 16, weight: .medium)
    }
    
    /// Small label - 10pt with tracking
    static func label() -> Font {
        .system(size: 10, weight: .regular)
    }
    
    /// Subheading - 16pt light
    static func subheading() -> Font {
        .system(size: 16, weight: .light)
    }
    
    /// Caption - 14pt regular
    static func caption() -> Font {
        .system(size: 14, weight: .regular)
    }
    
    
    // MARK: - Spacing
    
    /// Screen horizontal padding - 24pt
    static let screenPadding: CGFloat = 24
    
    /// Progress bar height - 4pt
    static let progressHeight: CGFloat = 4
    
    /// Card corner radius - 16pt
    static let cardRadius: CGFloat = 16
    
    /// Button corner radius - 28pt (fully rounded for 56pt height)
    static let buttonRadius: CGFloat = 28
    
    /// Button height - 56pt
    static let buttonHeight: CGFloat = 56
    
    /// Card internal padding - 20pt
    static let cardPadding: CGFloat = 20
    
    /// Vertical gap between cards - 12pt
    static let cardGap: CGFloat = 12
    
    /// Content top padding (below progress bar) - 48pt
    static let contentTop: CGFloat = 48
    
    /// Bottom button area reserve - 128pt
    static let bottomArea: CGFloat = 128
    
    /// Headline to body spacing - 8pt
    static let headlineBodyGap: CGFloat = 8
    
    /// Body to cards spacing - 32pt
    static let bodyCardsGap: CGFloat = 32
    
    
    // MARK: - Animation
    
    /// Standard transition duration
    static let transitionDuration: Double = 0.3
}
