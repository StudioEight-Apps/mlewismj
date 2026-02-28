import SwiftUI

/// Centralized, theme-aware color provider.
/// Initialize with the current `colorScheme` and access semantic color names.
///
/// Usage in any view:
/// ```
/// @Environment(\.colorScheme) var colorScheme
/// var colors: AppColors { AppColors(colorScheme) }
/// ```
struct AppColors {
    let scheme: ColorScheme

    init(_ scheme: ColorScheme) { self.scheme = scheme }

    private var dark: Bool { scheme == .dark }

    // MARK: - Backgrounds

    /// Main screen background (WelcomeView, etc.)
    var screenBackground: Color {
        dark ? Color(hex: "#050508") : Color(hex: "#FFFCF5")
    }

    /// Secondary screen background (prompts, settings, history)
    var secondaryBackground: Color {
        dark ? Color(hex: "#0A0A0F") : Color(hex: "#F5EFE7")
    }

    /// Card / surface background — solid fill, no material
    var card: Color {
        dark ? Color(hex: "#141418") : Color.white
    }

    /// Elevated card (one step above card) — for nested surfaces
    var cardElevated: Color {
        dark ? Color(hex: "#1A1A20") : Color.white
    }

    /// Frosty card overlay — solid dark fills, NO material blur
    @ViewBuilder var frostedCard: some View {
        if dark {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#141418"))
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        }
    }

    // MARK: - Text

    /// Primary text — crisp white in dark, near-black in light
    var primaryText: Color {
        dark ? Color(hex: "#EEEEEE") : Color(hex: "#2A2A2A")
    }

    /// Secondary / subtitle text
    var secondaryText: Color {
        dark ? Color(hex: "#8E8E93") : Color(hex: "#9A9088")
    }

    /// Tertiary / hint text
    var tertiaryText: Color {
        dark ? Color(hex: "#555560") : Color(hex: "#B5AA9A")
    }

    /// Muted text (timestamps, captions)
    var mutedText: Color {
        dark ? Color(hex: "#48484F") : Color(hex: "#6B6159")
    }

    // MARK: - Borders & Shadows

    /// Card border — thin, subtle definition
    var cardBorder: Color {
        dark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
    }

    /// Card shadow color
    var cardShadow: Color {
        dark ? Color.clear : Color.black.opacity(0.06)
    }

    /// Subtle inner shadow for depth
    var cardShadowLight: Color {
        dark ? Color.clear : Color.black.opacity(0.04)
    }

    // MARK: - Interactive

    /// Gold accent — stays consistent across themes
    static let gold = Color(hex: "#C4A574")

    /// Button / CTA background
    var buttonBackground: Color {
        dark ? Color.white : Color.black
    }

    /// Button text
    var buttonText: Color {
        dark ? Color.black : Color.white
    }

    /// Input field border
    var inputBorder: Color {
        dark ? Color.white.opacity(0.10) : Color(hex: "#E5E5EA")
    }

    /// Input focus border
    var inputFocusBorder: Color {
        dark ? AppColors.gold.opacity(0.5) : AppColors.gold.opacity(0.4)
    }

    // MARK: - Specific Components

    /// Prompt indicator capsule background
    var promptCapsule: Color {
        dark ? Color(hex: "#1A1A20") : Color(hex: "#EDE8E0")
    }

    /// Prompt indicator text
    var promptCapsuleText: Color {
        dark ? Color(hex: "#8E8E93") : Color(hex: "#6B6159")
    }

    /// Segmented control tint
    var segmentedTint: Color {
        dark ? Color.white : Color(hex: "#2A2A2A")
    }

    /// Calendar day unselected text
    var calendarDayText: Color {
        dark ? Color(hex: "#CCCCCC") : Color(hex: "#2A2A2A")
    }

    /// Calendar selected circle fill
    var calendarSelected: Color {
        dark ? Color.white : Color(hex: "#2A2A2A")
    }

    /// Calendar selected text
    var calendarSelectedText: Color {
        dark ? Color.black : Color.white
    }

    /// Streak capsule background
    var streakCapsule: Color {
        dark ? Color(hex: "#1A1A20") : Color(hex: "#F5F0E8")
    }

    /// Streak text
    var streakText: Color {
        dark ? Color(hex: "#8E8E93") : Color(hex: "#B5AA9A")
    }

    /// Divider / separator
    var divider: Color {
        dark ? Color.white.opacity(0.06) : Color(hex: "#EDE8E0")
    }

    /// Question card background (prompt screens)
    var questionCard: Color {
        dark ? Color(hex: "#141418") : Color.white
    }

    /// Question card shadow
    var questionCardShadow: Color {
        dark ? Color.clear : Color.black.opacity(0.08)
    }

    /// Toolbar icon tint
    var toolbarIcon: Color {
        dark ? Color(hex: "#8E8E93") : Color(hex: "#8A8078")
    }

    /// Navigation tint — bright and clear in both modes
    var navTint: Color {
        dark ? Color.white : Color(hex: "#2A2A2A")
    }

    /// Settings row background
    var settingsRow: Color {
        dark ? Color(hex: "#141418") : Color.white
    }

    /// Name prompt banner background
    var bannerBackground: Color {
        dark ? Color(hex: "#141418") : Color(hex: "#F5F0E8")
    }

    /// Placeholder text (input fields)
    var placeholder: Color {
        dark ? Color(hex: "#48484F") : Color(hex: "#999999")
    }

    /// Whisper actions icon color (unactive)
    var whisperActionIcon: Color {
        dark ? Color(hex: "#555560") : Color(hex: "#C8BFB2")
    }

    /// Action bar background — solid dark fill, no material
    @ViewBuilder var actionBarBackground: some View {
        if dark {
            Capsule().fill(Color(hex: "#1A1A20"))
        } else {
            ZStack {
                Capsule().fill(.thinMaterial)
                Capsule().fill(Color.black.opacity(0.03))
            }
        }
    }

    /// Action bar border
    var actionBarBorder: Color {
        dark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
    }

    /// Inactive action icon (detail view / summary view)
    var actionIconInactive: Color {
        dark ? Color(hex: "#6E6E78") : Color(hex: "#2A2A2A").opacity(0.5)
    }

    /// Detail view page background
    var detailBackground: Color {
        dark ? Color(hex: "#050508") : Color(hex: "#FFFCF5")
    }

    /// Reflection card background
    var reflectionCard: Color {
        dark ? Color(hex: "#141418") : Color.white
    }

    /// Mood badge text
    var moodBadgeText: Color { .white }

    /// Loading screen dots color
    var loadingDots: Color { AppColors.gold }

    /// Empty state icon color
    var emptyStateIcon: Color {
        dark ? Color(hex: "#48484F") : Color(hex: "#5B5564")
    }

    /// Text editor scrollable background
    var editorBackground: Color {
        dark ? Color(hex: "#0A0A0F") : Color(hex: "#F5EFE7")
    }

    // MARK: - Journal Flow Specific

    /// Disabled button background (Continue buttons when nothing selected)
    var buttonDisabled: Color {
        dark ? Color(hex: "#1A1A20") : Color(hex: "#E8E4DC")
    }

    /// Disabled button text
    var buttonDisabledText: Color {
        dark ? Color(hex: "#48484F") : Color(hex: "#9B9B9B")
    }

    /// Unselected mood pill background
    var moodPillUnselected: Color {
        dark ? Color(hex: "#141418") : Color(hex: "#EDE6DC")
    }

    /// Mood pill text
    var moodPillText: Color {
        dark ? Color(hex: "#CCCCCC") : Color(hex: "#2C2C2C")
    }

    /// Mood pill border (unselected)
    var moodPillBorder: Color {
        dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04)
    }

    /// Journal card unselected bg
    var journalCardUnselected: Color {
        dark ? Color(hex: "#141418") : Color.white
    }

    /// Journal card unselected border
    var journalCardBorder: Color {
        dark ? Color.white.opacity(0.06) : Color(hex: "#E5E5E5")
    }

    /// Journal card icon inactive
    var journalCardIconInactive: Color {
        dark ? Color(hex: "#48484F") : Color(hex: "#B5B5B5")
    }

    /// Description text in journal cards
    var descriptionText: Color {
        dark ? Color(hex: "#6E6E78") : Color(hex: "#6B6159")
    }

    /// Hint text (smaller notes)
    var hintText: Color {
        dark ? Color(hex: "#555560") : Color(hex: "#6B6159")
    }

    /// Selector circle border (unselected)
    var selectorCircleBorder: Color {
        dark ? Color(hex: "#3A3A42") : Color(hex: "#D0D0D0")
    }

    /// Background fade gradient color (for bottom floating buttons)
    var backgroundFade: Color {
        dark ? Color(hex: "#0A0A0F") : Color(hex: "#F5EFE7")
    }

    /// Screen fade for modal backgrounds
    var screenFade: Color {
        dark ? Color(hex: "#050508") : Color(hex: "#FFFCF5")
    }

    /// Filter chip active bg
    var filterChipActive: Color {
        dark ? Color.white : Color(hex: "#1A1A1A")
    }

    /// Filter chip active text
    var filterChipActiveText: Color {
        dark ? Color.black : Color.white
    }

    /// Filter chip inactive bg
    var filterChipInactive: Color {
        dark ? Color(hex: "#141418") : Color(hex: "#F0F0F0")
    }

    /// Filter chip inactive text
    var filterChipInactiveText: Color {
        dark ? Color(hex: "#8E8E93") : Color(hex: "#3D3D3D")
    }

    /// Continue button circle (MantraSummaryView)
    var continueCircle: Color {
        dark ? Color(hex: "#1A1A20") : Color.black.opacity(0.04)
    }

    /// Continue circle border
    var continueCircleBorder: Color {
        dark ? Color.white.opacity(0.06) : Color.black.opacity(0.08)
    }

    /// Continue circle icon
    var continueCircleIcon: Color {
        dark ? Color(hex: "#EEEEEE").opacity(0.8) : Color(hex: "#2A2A2A").opacity(0.7)
    }

    /// Calendar popup bg (dark)
    var calendarPopup: Color {
        dark ? Color(hex: "#141418") : Color.white
    }
}
