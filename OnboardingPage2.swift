import SwiftUI

struct OnboardingPage2: View {
    var body: some View {
        ZStack {
            // Background - properly scaled to fill screen
            Image("bg2_cream_scribble_dense")
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
                    Text("Your inner voice can be harsh.")
                        .font(.system(size: 30, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .multilineTextAlignment(.center)
                        .tracking(0.5)
                        .frame(maxWidth: 360)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Whisper helps you replace harsh thoughts with better ones, with positive guidance throughout the day.")
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
