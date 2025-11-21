import SwiftUI

struct OnboardingPage1: View {
    var body: some View {
        ZStack {
            // Background - properly scaled to fill screen
            Image("bg1_cream_scribble")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
            
            // Content overlay
            VStack(spacing: 0) {
                // Logo at top
                Image("whisper-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 28)
                    .padding(.top, 60)
                
                Spacer()
                
                // Text content - centered
                VStack(spacing: 14) {
                    Text("Your thoughts were meant to pass through, not live inside you.")
                        .font(.system(size: 30, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .multilineTextAlignment(.center)
                        .tracking(0.5)
                        .frame(maxWidth: 360)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Give your mind space to breathe, your journal can hold the rest.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(hex: "#2A2A2A").opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: 360)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                Spacer()
            }
        }
        .background(Color(hex: "#FFFCF5"))
    }
}
