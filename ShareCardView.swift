import SwiftUI

struct ShareCardView: View {
    let whisperText: String
    let timestamp: String?
    let mood: String?
    let preset: SharePreset
    
    // Hide share button in export
    let hideShareButton: Bool
    
    init(
        whisperText: String,
        timestamp: String? = nil,
        mood: String? = nil,
        preset: SharePreset = .feed,
        hideShareButton: Bool = true
    ) {
        self.whisperText = whisperText
        self.timestamp = timestamp
        self.mood = mood
        self.preset = preset
        self.hideShareButton = hideShareButton
    }
    
    var body: some View {
        ZStack {
            // Background matching app
            Color(hex: "#FFFCF5")
                .ignoresSafeArea()
            
            // Card container
            VStack(spacing: 0) {
                // Label
                Text("Today's Whisper")
                    .font(.system(size: 14, weight: .medium))
                    .tracking(0.14)
                    .foregroundColor(Color(hex: "#6A6A6A"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
                
                // Whisper text
                Text(whisperText)
                    .font(.system(size: scaledFontSize, weight: .semibold))
                    .foregroundColor(Color(hex: "#2B2B2B"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(lineSpacing)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, bottomPadding)
                
                // Optional metadata
                if let timestamp = timestamp, let mood = mood {
                    HStack {
                        Text(timestamp)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(hex: "#8C8C8C"))
                        
                        Spacer()
                        
                        Text(mood.uppercased())
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(hex: "#8C8C8C"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
            .frame(width: cardWidth, height: cardHeight)
            .background(Color(hex: "#F5F0E8"))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(hex: "#E9E2D6"), lineWidth: 1)
            )
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
        }
        .frame(width: preset.size.width, height: preset.size.height)
    }
    
    // Scale card and typography based on export size
    private var cardWidth: CGFloat {
        switch preset {
        case .feed:
            return 860  // 80% of 1080
        case .square:
            return 860
        case .story:
            return 860
        }
    }
    
    private var cardHeight: CGFloat {
        switch preset {
        case .feed:
            return 680  // Proportional for 4:5
        case .square:
            return 860  // Square
        case .story:
            return 1200 // Taller for story
        }
    }
    
    private var scaledFontSize: CGFloat {
        switch preset {
        case .feed, .square:
            return 52  // ~2.7x larger for crisp export
        case .story:
            return 56  // Slightly larger for story format
        }
    }
    
    private var lineSpacing: CGFloat {
        switch preset {
        case .feed, .square:
            return 14
        case .story:
            return 16
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch preset {
        case .feed, .square:
            return 60
        case .story:
            return 80
        }
    }
    
    private var bottomPadding: CGFloat {
        return 40
    }
}
