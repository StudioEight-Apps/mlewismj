import SwiftUI

struct BackgroundSelectorModal: View {
    @Environment(\.dismiss) var dismiss
    let mantra: String
    let onSelect: (BackgroundConfig) -> Void
    
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    
    private let backgrounds = BackgroundConfig.allBackgrounds
    private let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.75
    private let cardHeight: CGFloat = UIScreen.main.bounds.width * 0.75
    
    private var cleanedMantra: String {
        let terminalPunctuation = CharacterSet(charactersIn: ".,;:!?…")
        var cleaned = mantra.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = cleaned.last, terminalPunctuation.contains(String(last).unicodeScalars.first!) {
            cleaned = String(cleaned.dropLast())
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FFFCF5"),
                    Color(hex: "#F5EFE6")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Choose Background")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Page indicator
                HStack(spacing: 6) {
                    ForEach(0..<backgrounds.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color(hex: "#A6B4FF") : Color(hex: "#D0D0D0"))
                            .frame(width: index == currentIndex ? 8 : 6, height: index == currentIndex ? 8 : 6)
                            .animation(.spring(response: 0.3), value: currentIndex)
                    }
                }
                .padding(.bottom, 24)
                
                // Carousel
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        ForEach(Array(backgrounds.enumerated()), id: \.offset) { index, background in
                            backgroundCard(background: background, index: index, geometry: geometry)
                        }
                    }
                    .offset(x: CGFloat(-currentIndex) * (cardWidth + 20) + dragOffset + (geometry.size.width - cardWidth) / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                let velocity = value.predictedEndTranslation.width - value.translation.width
                                
                                if value.translation.width < -threshold || velocity < -100 {
                                    if currentIndex < backgrounds.count - 1 {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            currentIndex += 1
                                        }
                                    }
                                } else if value.translation.width > threshold || velocity > 100 {
                                    if currentIndex > 0 {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            currentIndex -= 1
                                        }
                                    }
                                }
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    dragOffset = 0
                                }
                            }
                    )
                }
                .frame(height: cardHeight + 40)
                
                Spacer()
                
                // Continue button
                Button {
                    let selectedBackground = backgrounds[currentIndex]
                    onSelect(selectedBackground)
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .cornerRadius(28)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func backgroundCard(background: BackgroundConfig, index: Int, geometry: GeometryProxy) -> some View {
        let scale = currentIndex == index ? 1.0 : 0.9
        let opacity = currentIndex == index ? 1.0 : 0.6
        
        return ZStack {
            Image(background.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: cardWidth, height: cardHeight)
                .clipped()
            
            VStack(spacing: 20) {
                Text(cleanedMantra)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: background.textColor))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .lineSpacing(4)
                    .tracking(-0.4)
                    .minimumScaleFactor(0.75)
                    .allowsTightening(true)
                    .frame(maxWidth: cardWidth - 56)
                
                Image("whisper-logo")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: cardWidth * 0.13)
                    .foregroundColor(Color(hex: background.textColor))
                    .opacity(0.82)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .scaleEffect(scale)
        .opacity(opacity)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentIndex)
    }
}
