import SwiftUI

struct OnboardingPage3: View {
    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            let availableHeight = geometry.size.height - safeArea.top - safeArea.bottom
            
            VStack(spacing: 0) {
                // Fixed high positioning - moved up 75%
                Spacer()
                    .frame(height: (min(safeArea.top + 5, 60)) * 0.25) // 75% higher positioning
                
                // Logo positioned high and consistently across all devices
                Text("mantra")
                    .font(.system(size: 25.92, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                
                // Icon starts below logo with more space (matching page 1)
                Spacer()
                    .frame(height: availableHeight * 0.14) // Increased from 0.08 to match page 1
                
                HStack {
                    Spacer()
                    Image("onboarding_icon_s3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: availableHeight * 0.24) // Increased by 20% to match page 1
                        .frame(maxWidth: geometry.size.width * 0.80)
                    Spacer()
                }
                
                // Gap: Icon to title - 5%
                Spacer()
                    .frame(height: availableHeight * 0.05)
                
                // Title - single line, shrink font to fit
                HStack {
                    Spacer()
                    Text("Build habits that help")
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
                    Text("Just a few minutes a day builds clarity balance and focus. With Mantra reflection becomes a lasting habit that strengthens your daily routine.")
                        .font(.system(size: 15, weight: .regular)) // Reduced from 16 to 15
                        .foregroundColor(Color(hex: "#7A7A7A"))
                        .multilineTextAlignment(.center)
                        .lineLimit(4) // Increased from 3 to 4 lines
                        .lineSpacing(3) // Reduced line spacing from 4 to 3
                        .frame(maxWidth: geometry.size.width * 0.80) // Increased from 0.75 to 0.80
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
