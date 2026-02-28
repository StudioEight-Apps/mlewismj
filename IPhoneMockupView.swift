import SwiftUI

struct IPhoneMockupView<Content: View>: View {
    let content: Content
    let fadeBottom: Bool
    
    init(fadeBottom: Bool = false, @ViewBuilder content: () -> Content) {
        self.fadeBottom = fadeBottom
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // iPhone Frame
            RoundedRectangle(cornerRadius: 50)
                .fill(Color(hex: "#1a1a1a"))
                .frame(width: 280, height: 590)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Screen Container
            RoundedRectangle(cornerRadius: 40)
                .fill(.black)
                .frame(width: 260, height: 570)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .overlay(
                    // Screen Content
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.clear)
                        .frame(width: 260, height: 560)
                        .clipped()
                        .overlay(
                            content
                                .frame(width: 260, height: 560)
                                .clipped()
                        )
                )
            
            // Dynamic Island
            RoundedRectangle(cornerRadius: 14)
                .fill(.black)
                .frame(width: 100, height: 28)
                .offset(y: -268)
            
            // Fade overlay (bottom half)
            if fadeBottom {
                LinearGradient(
                    colors: [
                        .black.opacity(0),
                        .black.opacity(0.95),
                        .black
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(width: 280, height: 295)
                .offset(y: 147.5)
                .allowsHitTesting(false)
            }
        }
    }
}
