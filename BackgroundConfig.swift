import SwiftUI

// MARK: - Background Configuration
struct BackgroundConfig {
    let imageName: String
    let textColor: String
    
    // All 20 backgrounds (10 original + 10 new)
    static let allBackgrounds: [BackgroundConfig] = [
        // Original 10 backgrounds
        BackgroundConfig(imageName: "whisper_bg_01_bone", textColor: "#1E1B19"),
        BackgroundConfig(imageName: "whisper_bg_02_sand", textColor: "#1E1B19"),
        BackgroundConfig(imageName: "whisper_bg_03_taupe", textColor: "#1E1B19"),
        BackgroundConfig(imageName: "whisper_bg_04_clay", textColor: "#EAD8C9"),
        BackgroundConfig(imageName: "whisper_bg_05_terracotta", textColor: "#F2E2D6"),
        BackgroundConfig(imageName: "whisper_bg_06_olive", textColor: "#E6EAD9"),
        BackgroundConfig(imageName: "whisper_bg_07_sage", textColor: "#DDE7DC"),
        BackgroundConfig(imageName: "whisper_bg_08_moss", textColor: "#DFE7D6"),
        BackgroundConfig(imageName: "whisper_bg_09_cacao", textColor: "#ECDDC7"),
        BackgroundConfig(imageName: "whisper_bg_10_charcoal", textColor: "#E8DEC9"),
        
        // New 10 backgrounds
        BackgroundConfig(imageName: "blue_static", textColor: "#F9C99D"),
        BackgroundConfig(imageName: "forest_green", textColor: "#C5FFB3"),
        BackgroundConfig(imageName: "orange_blue_gradient", textColor: "#FCEBD4"),
        BackgroundConfig(imageName: "orange_blue_blend", textColor: "#FFD9A0"),
        BackgroundConfig(imageName: "static_texture", textColor: "#E8CBD8"),
        BackgroundConfig(imageName: "wrinkled_paper", textColor: "#D63C28"),
        BackgroundConfig(imageName: "sunkissed_whisper", textColor: "#422C10"),
        BackgroundConfig(imageName: "whisper_bg_cream", textColor: "#C22716"),
        BackgroundConfig(imageName: "whisper_bg_deepreds", textColor: "#FDE8C1"),
        BackgroundConfig(imageName: "whisper_bg_goldenblend", textColor: "#4B2E0A")
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
