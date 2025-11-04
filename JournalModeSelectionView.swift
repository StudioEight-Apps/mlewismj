import SwiftUI

struct JournalModeSelectionView: View {
    @State private var selectedType: JournalType? = nil
    @State private var cardScale: [JournalType: CGFloat] = [.guided: 1.0, .free: 1.0]
    
    var body: some View {
        ZStack {
                // Background matching app theme
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FFFCF5"),
                        Color(hex: "#FBF8F2")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 30)
                    
                    // Title
                    Text("How would you like\nto journal today?")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 50)
                    
                    // Card stack
                    VStack(spacing: 20) {
                        // Guided Journal Card
                        journalTypeCard(
                            type: .guided,
                            icon: "star",
                            title: "Guided Journal",
                            description: "Answer thoughtful prompts\ndesigned for your mood.",
                            accentColor: Color(hex: "#A6B4FF")
                        )
                        
                        // Free Journal Card
                        journalTypeCard(
                            type: .free,
                            icon: "pencil",
                            title: "Free Journal",
                            description: "Write freely, no structure —\njust your thoughts.",
                            accentColor: Color(hex: "#C4B5A0")
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Continue Button
                    NavigationLink(destination: Group {
                        if let type = selectedType {
                            NewMantraView(journalType: type)
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(selectedType != nil ? .white : Color(hex: "#9B9B9B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedType != nil ? Color(hex: "#A6B4FF") : Color(hex: "#F0F0F0"))
                                    .shadow(
                                        color: selectedType != nil ? Color(hex: "#A6B4FF").opacity(0.3) : Color.clear,
                                        radius: selectedType != nil ? 12 : 0,
                                        x: 0,
                                        y: selectedType != nil ? 6 : 0
                                    )
                            )
                    }
                    .disabled(selectedType == nil)
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(selectedType != nil ? 1.0 : 0.98)
                    .opacity(selectedType != nil ? 1.0 : 0.6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedType)
                    .simultaneousGesture(TapGesture().onEnded {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    })
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
        }
    }
    
    private func journalTypeCard(
        type: JournalType,
        icon: String,
        title: String,
        description: String,
        accentColor: Color
    ) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedType = type
            }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(selectedType == type ? accentColor : Color(hex: "#B5B5B5"))
                    .frame(height: 40)
                
                // Title
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                
                // Description
                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "#6E6E73"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedType == type ? accentColor.opacity(0.08) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                selectedType == type ? accentColor.opacity(0.4) : Color(hex: "#E5E5E5"),
                                lineWidth: selectedType == type ? 2 : 1
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(selectedType == type ? 0.08 : 0.04),
                        radius: selectedType == type ? 12 : 4,
                        x: 0,
                        y: selectedType == type ? 4 : 2
                    )
            )
        }
        .buttonStyle(JournalModeCardButtonStyle())
        .scaleEffect(cardScale[type] ?? 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedType)
    }
}

// Custom button style for cards with subtle press effect
struct JournalModeCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// Color(hex:) extension already exists in the project - reusing it
