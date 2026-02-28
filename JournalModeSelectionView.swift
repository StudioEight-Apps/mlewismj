import SwiftUI

struct JournalModeSelectionView: View {
    var preSelectedType: JournalType? = nil
    @State private var selectedType: JournalType? = nil
    @State private var cardScale: [JournalType: CGFloat] = [.guided: 1.0, .free: 1.0]
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    var body: some View {
        ZStack {
            colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                // Title - SERIF FONT for headings
                Text("How would you like\nto journal today?")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundColor(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 40)

                // Card stack
                VStack(spacing: 16) {
                    // Guided Journal Card
                    journalTypeCard(
                        type: .guided,
                        icon: "sparkles",
                        title: "Guided Journal",
                        description: "Answer thoughtful prompts\ndesigned for your mood.",
                        accentColor: Color(hex: "#C4A574")
                    )

                    // Free Journal Card
                    journalTypeCard(
                        type: .free,
                        icon: "pencil.line",
                        title: "Free Journal",
                        description: "Write freely, no structure —\njust your thoughts.",
                        accentColor: Color(hex: "#8B9A7D")
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
                        .foregroundColor(selectedType != nil ? colors.buttonText : colors.buttonDisabledText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(selectedType != nil ? colors.buttonBackground : colors.buttonDisabled)
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
        .tint(colors.navTint)
        .onAppear {
            if let preSelected = preSelectedType, selectedType == nil {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    selectedType = preSelected
                }
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
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(selectedType == type ? accentColor : colors.journalCardIconInactive)
                    .frame(width: 44, height: 44)

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colors.primaryText)

                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(colors.descriptionText)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                }

                Spacer()

                // Selection indicator
                Circle()
                    .fill(selectedType == type ? accentColor : Color.clear)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .stroke(selectedType == type ? accentColor : colors.selectorCircleBorder, lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(selectedType == type ? 1 : 0)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedType == type ? accentColor.opacity(colorScheme == .dark ? 0.12 : 0.08) : colors.journalCardUnselected)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedType == type ? accentColor.opacity(0.4) : colors.journalCardBorder,
                                lineWidth: selectedType == type ? 2 : 1
                            )
                    )
                    .shadow(
                        color: colorScheme == .dark ? Color.clear : Color.black.opacity(selectedType == type ? 0.08 : 0.04),
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
