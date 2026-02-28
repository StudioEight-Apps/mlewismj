import SwiftUI

// MARK: - Text Position Enum
enum TextPosition {
    case topLeft
    case topCenter
    case topRight
    case center
    case bottomLeft
    case bottomRight
}

// MARK: - Text Alignment
enum TextAlignmentStyle {
    case left
    case center
    case right
    
    var swiftUIAlignment: TextAlignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }
}

// MARK: - Background Category
enum BackgroundCategory: String, CaseIterable {
    case color = "Color"
    case textured = "Textured"

    var icon: String {
        switch self {
        case .color: return "icon-palette"
        case .textured: return "icon-blueprint"
        }
    }
}

// MARK: - Background Configuration
struct BackgroundConfig: Equatable {
    let imageName: String
    let textColor: String
    let textPosition: TextPosition
    let textAlignment: TextAlignmentStyle
    let categories: [BackgroundCategory]
    let maxWidthMultiplier: CGFloat
    let widgetImageAlignment: Alignment
    let screenBackgroundHex: String
    
    init(
        imageName: String,
        textColor: String,
        textPosition: TextPosition = .center,
        textAlignment: TextAlignmentStyle = .center,
        categories: [BackgroundCategory] = [.color],
        maxWidthMultiplier: CGFloat = 0.85,
        widgetImageAlignment: Alignment = .center,
        screenBackgroundHex: String = "#F5EFE7"
    ) {
        self.imageName = imageName
        self.textColor = textColor
        self.textPosition = textPosition
        self.textAlignment = textAlignment
        self.categories = categories
        self.maxWidthMultiplier = maxWidthMultiplier
        self.widgetImageAlignment = widgetImageAlignment
        self.screenBackgroundHex = screenBackgroundHex
    }
    
    // MARK: - All Backgrounds (12 Total)
    static let allBackgrounds: [BackgroundConfig] = [
        
        // ============================================
        // COLOR TAB (8 backgrounds)
        // ============================================
        
        BackgroundConfig(
            imageName: "forest_green",
            textColor: "#C5FFB3",
            textPosition: .center,
            textAlignment: .center,
            categories: [.color],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "whisper_bg_deepreds",
            textColor: "#F5EDE5",
            textPosition: .center,
            textAlignment: .center,
            categories: [.color],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "sunkissed_whisper",
            textColor: "#42210B",
            textPosition: .center,
            textAlignment: .center,
            categories: [.color],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "whisper_bg_cream",
            textColor: "#1F2E78",
            textPosition: .center,
            textAlignment: .center,
            categories: [.color],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "whisper_bg_goldenblend",
            textColor: "#3E2A1C",
            textPosition: .center,
            textAlignment: .center,
            categories: [.color],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "blue_static",
            textColor: "#F9C99D",
            textPosition: .center,
            textAlignment: .center,
            categories: [.color],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "whisper_bg_espressofade",
            textColor: "#EEDFCB",
            textPosition: .center,
            textAlignment: .center,
            categories: [.color],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "whisper_color_poeticwine",
            textColor: "#F4F1EC",
            textPosition: .center,
            textAlignment: .center,
            categories: [.color],
            screenBackgroundHex: "#F5EFE7"
        ),
        
        // ============================================
        // TEXTURED TAB (4 backgrounds)
        // ============================================
        
        BackgroundConfig(
            imageName: "whisper_texture_peeledpaper",
            textColor: "#1A1A1A",
            textPosition: .center,
            textAlignment: .center,
            categories: [.textured],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "whisper_texture_bluetexture",
            textColor: "#2F2F2F",
            textPosition: .center,
            textAlignment: .center,
            categories: [.textured],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "whisper_bg_crinkledbeige",
            textColor: "#5B3520",
            textPosition: .center,
            textAlignment: .center,
            categories: [.textured],
            screenBackgroundHex: "#F5EFE7"
        ),
        BackgroundConfig(
            imageName: "whisper_bg_charcoalgrain",
            textColor: "#F5E8D8",
            textPosition: .center,
            textAlignment: .center,
            categories: [.textured],
            screenBackgroundHex: "#F5EFE7"
        ),
    ]
    
    // MARK: - Helper Methods
    static func backgrounds(for category: BackgroundCategory) -> [BackgroundConfig] {
        allBackgrounds.filter { $0.categories.contains(category) }
    }
    
    static func random() -> BackgroundConfig {
        allBackgrounds.randomElement() ?? allBackgrounds[0]
    }
    
    static func textColor(for imageName: String) -> String {
        allBackgrounds.first(where: { $0.imageName == imageName })?.textColor ?? "#1E1B19"
    }
    
    static func screenBackground(for imageName: String) -> String {
        allBackgrounds.first(where: { $0.imageName == imageName })?.screenBackgroundHex ?? "#F5EFE7"
    }
    
    static func widgetAlignmentString(for imageName: String) -> String {
        let alignment = allBackgrounds.first(where: { $0.imageName == imageName })?.widgetImageAlignment ?? .center
        
        switch alignment {
        case .top: return "top"
        case .bottom: return "bottom"
        default: return "center"
        }
    }
    
    // MARK: - Equatable
    static func == (lhs: BackgroundConfig, rhs: BackgroundConfig) -> Bool {
        lhs.imageName == rhs.imageName
    }
}
