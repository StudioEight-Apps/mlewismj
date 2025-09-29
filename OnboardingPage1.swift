import SwiftUI

struct OnboardingPage1: View {
    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            let availableHeight = geometry.size.height - safeArea.top - safeArea.bottom
            
            ZStack {
                // Subtle gradient background for depth
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FFFCF5"),
                        Color(hex: "#FFF9ED")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo positioning - very high
                    Spacer()
                        .frame(height: safeArea.top + 10)
                    
                    // Whisper logo - positioned as high as possible
                    Image("whisper-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                    
                    // Spacing between logo and icon
                    Spacer()
                        .frame(height: availableHeight * 0.08)
                    
                    // Illustration - larger and more prominent
                    HStack {
                        Spacer()
                        Image("onboarding_icon_s1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: availableHeight * 0.28)
                            .frame(maxWidth: geometry.size.width * 0.75)
                        Spacer()
                    }
                    
                    // Gap between icon and title
                    Spacer()
                        .frame(height: availableHeight * 0.06)
                    
                    // Title - single line
                    Text("A heavy mind hurts")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 32)
                    
                    // Gap between title and body
                    Spacer()
                        .frame(height: availableHeight * 0.025)
                    
                    // Body - slightly larger and better weight
                    HStack {
                        Spacer()
                        Text("By putting feelings into words, you release what weighs on you and make room for peace to return.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "#666666"))
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .lineSpacing(4)
                            .frame(maxWidth: geometry.size.width * 0.82)
                        Spacer()
                    }
                    
                    // Fill remaining space
                    Spacer()
                    
                    // Bottom safe area
                    Spacer()
                        .frame(height: max(safeArea.bottom, 20))
                }
            }
        }
        .ignoresSafeArea(.all, edges: .all)
    }
}
