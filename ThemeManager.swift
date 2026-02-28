import SwiftUI

/// Controls the app-wide appearance mode (light / dark / system).
/// Persists the user's choice in UserDefaults.
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    /// Raw stored value: "light", "dark", or "system"
    @AppStorage("appAppearance") var appearanceRaw: String = "dark" {
        didSet { objectWillChange.send() }
    }

    /// Resolved SwiftUI color scheme.  `nil` = follow system.
    var preferredColorScheme: ColorScheme? {
        switch appearanceRaw {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil   // system
        }
    }

    var displayName: String {
        switch appearanceRaw {
        case "light": return "Light"
        case "dark":  return "Dark"
        default:      return "System"
        }
    }
}
