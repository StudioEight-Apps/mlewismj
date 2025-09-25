import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @Binding var isShowingSplash: Bool
    
    var body: some View {
        ZStack {
            Color(hex: "#FFFCF5")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Whisper logo - properly sized for splash
                Image("whisper-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180)
                    .accessibilityLabel("Whisper")
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.3)
                
                // Subtle tagline
                Text("smart journal")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(Color(hex: "#888888"))
                    .opacity(isAnimating ? 0.8 : 0.0)
            }
        }
        .onAppear {
            // Animate logo in
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
            
            // Dismiss splash after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isShowingSplash = false
                }
            }
        }
    }
}
