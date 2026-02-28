import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @Binding var isShowingSplash: Bool
    
    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A")
                .ignoresSafeArea()

            // Whisper logo - light on dark
            Image("whisper-logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 180)
                .foregroundColor(Color(hex: "#F5EFE7"))
                .accessibilityLabel("Whisper")
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.3)
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
