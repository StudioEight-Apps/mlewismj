import SwiftUI

// MARK: - Background Configuration
struct BackgroundConfig {
    let imageName: String
    let textColor: String
    
    // All 12 curated backgrounds
    static let allBackgrounds: [BackgroundConfig] = [
        BackgroundConfig(imageName: "sunset_teal_blend", textColor: "#F3EDE0"),
        BackgroundConfig(imageName: "whisper_bg_crinkledbeige", textColor: "#5B3520"),
        BackgroundConfig(imageName: "forest_green", textColor: "#C5FFB3"),
        BackgroundConfig(imageName: "whisper_bg_deepreds", textColor: "#F5EDE5"),
        BackgroundConfig(imageName: "sunkissed_whisper", textColor: "#42210B"),
        BackgroundConfig(imageName: "whisper_bg_cream", textColor: "#1F2E78"),
        BackgroundConfig(imageName: "whisper_bg_goldenblend", textColor: "#3E2A1C"),
        BackgroundConfig(imageName: "whisper_bg_orangebluefade", textColor: "#E4B7A0"),
        BackgroundConfig(imageName: "whisper_bg_amberforest", textColor: "#EEDDB4"),
        BackgroundConfig(imageName: "blue_static", textColor: "#F9C99D"),
        BackgroundConfig(imageName: "whisper_bg_charcoalgrain", textColor: "#F5E8D8"),
        BackgroundConfig(imageName: "whisper_bg_espressofade", textColor: "#EEDFCB")
    ]
    
    // Get a random background
    static func random() -> BackgroundConfig {
        return allBackgrounds.randomElement() ?? allBackgrounds[0]
    }
    
    // Get text color for a specific background
    static func textColor(for imageName: String) -> String {
        return allBackgrounds.first(where: { $0.imageName == imageName })?.textColor ?? "#1E1B19"
    }
}
