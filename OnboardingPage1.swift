import SwiftUI

struct OnboardingPage1: View {
    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            let availableHeight = geometry.size.height - safeArea.top - safeArea.bottom
            
            VStack(spacing: 0) {
                // Fixed high positioning - moved up 75%
                Spacer()
                    .frame(height: (min(safeArea.top + 5, 60)) * 0.25) // 75% higher positioning
                
                // Whisper logo positioned high and consistently across all devices
                Text("whisper")
                    .font(.system(size: 25.92, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                
                // Icon starts below logo with more space (slightly increased to compensate)
                Spacer()
                    .frame(height: availableHeight * 0.14) // Increased from 0.12 to maintain proportions
                
                HStack {
                    Spacer()
                    Image("onboarding_icon_s1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: availableHeight * 0.24) // Increased by 20% (was 0.20, now 0.24)
                        .frame(maxWidth: geometry.size.width * 0.80)
                    Spacer()
                }
                
                // Gap: Icon to title - 5%
                Spacer()
                    .frame(height: availableHeight * 0.05)
                
                // Title - single line, shrink font to fit
                HStack {
                    Spacer()
                    Text("Your mind feels heavy")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: geometry.size.width * 0.70)
                    Spacer()
                }
                
                // Gap: Title to body - 3%
                Spacer()
                    .frame(height: availableHeight * 0.03)
                
                // Body - 2-3 lines target
                HStack {
                    Spacer()
                    Text("Deep journaling gives your thoughts space to breathe and release. Whisper never judges and each session gives reassurance to lighten the load.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(hex: "#7A7A7A"))
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .lineSpacing(3)
                        .frame(maxWidth: geometry.size.width * 0.80)
                    Spacer()
                }
                
                // Fill remaining space
                Spacer()
                
                // Bottom safe area
                Spacer()
                    .frame(height: safeArea.bottom)
            }
        }
        .background(Color(hex: "#FFFCF5"))
        .ignoresSafeArea(.all, edges: .all)
    }
}
