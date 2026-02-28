import SwiftUI

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let progress: Double  // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(OnboardingTheme.progressTrack)
                
                // Fill
                Rectangle()
                    .fill(OnboardingTheme.accent)
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: OnboardingTheme.progressHeight)
    }
}


// MARK: - Continue Button

struct OnboardingContinueButton: View {
    let label: String
    let action: () -> Void
    var isEnabled: Bool = true
    var style: ButtonStyleType = .gold
    
    enum ButtonStyleType {
        case gold
        case dark
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                action()
            }) {
                Text(label)
                    .font(OnboardingTheme.button())
                    .foregroundColor(OnboardingTheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: OnboardingTheme.buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: OnboardingTheme.buttonRadius)
                            .fill(isEnabled ? OnboardingTheme.buttonBlack : OnboardingTheme.buttonBlack.opacity(0.35))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, 48)
        }
    }
}


// MARK: - Selectable Card (for mental audit screens)

struct OnboardingSelectableCard: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            Text(text)
                .font(OnboardingTheme.cardText())
                .foregroundColor(OnboardingTheme.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(OnboardingTheme.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardRadius)
                        .fill(isSelected ? OnboardingTheme.cardSelected : OnboardingTheme.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardRadius)
                        .stroke(isSelected ? OnboardingTheme.accent : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Quote Card (for voice selection)

struct OnboardingQuoteCard: View {
    let quote: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            Text("\"\(quote)\"")
                .font(OnboardingTheme.quoteText())
                .foregroundColor(OnboardingTheme.foreground)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 80)
                .padding(OnboardingTheme.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardRadius)
                        .fill(isSelected ? OnboardingTheme.cardSelected : OnboardingTheme.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardRadius)
                        .stroke(isSelected ? OnboardingTheme.accent : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Question Layout (standard layout for audit/selection screens)

struct OnboardingQuestionLayout<Content: View>: View {
    let progress: Double
    let headline: String
    let subheadline: String
    let buttonLabel: String
    let onContinue: () -> Void
    var canContinue: Bool = true
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            OnboardingTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                OnboardingProgressBar(progress: progress)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Headline
                        Text(headline)
                            .font(OnboardingTheme.headline())
                            .foregroundColor(OnboardingTheme.foreground)
                            .lineSpacing(4)
                        
                        // Subheadline
                        Text(subheadline)
                            .font(OnboardingTheme.body())
                            .foregroundColor(OnboardingTheme.muted)
                            .padding(.top, OnboardingTheme.headlineBodyGap)
                        
                        // Content (cards)
                        VStack(spacing: OnboardingTheme.cardGap) {
                            content()
                        }
                        .padding(.top, OnboardingTheme.bodyCardsGap)
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                    .padding(.top, OnboardingTheme.contentTop)
                    .padding(.bottom, 140)
                }
            }
            
            OnboardingContinueButton(
                label: buttonLabel,
                action: onContinue,
                isEnabled: canContinue
            )
        }
    }
}


// MARK: - Centered Content Layout (for intro/reveal screens)

struct OnboardingCenteredLayout: View {
    let progress: Double
    let buttonLabel: String
    let onContinue: () -> Void
    let content: AnyView
    
    init(
        progress: Double,
        buttonLabel: String = "Continue",
        onContinue: @escaping () -> Void,
        @ViewBuilder content: () -> some View
    ) {
        self.progress = progress
        self.buttonLabel = buttonLabel
        self.onContinue = onContinue
        self.content = AnyView(content())
    }
    
    var body: some View {
        ZStack {
            OnboardingTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                OnboardingProgressBar(progress: progress)
                
                Spacer()
                
                content
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                
                Spacer()
                
                // Reserve space for button
                Spacer().frame(height: 120)
            }
            
            OnboardingContinueButton(
                label: buttonLabel,
                action: onContinue
            )
        }
    }
}


// MARK: - Auth Button Styles

struct AppleButtonStyle: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "applelogo")
                    .font(.system(size: 18, weight: .medium))
                Text("Continue with Apple")
                    .font(OnboardingTheme.button())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: OnboardingTheme.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: OnboardingTheme.buttonRadius)
                    .fill(OnboardingTheme.buttonBlack)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GoogleButtonStyle: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Google "G" logo - using text as fallback
                Text("G")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
                Text("Continue with Google")
                    .font(OnboardingTheme.button())
                    .foregroundColor(OnboardingTheme.foreground)
            }
            .frame(maxWidth: .infinity)
            .frame(height: OnboardingTheme.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: OnboardingTheme.buttonRadius)
                    .fill(OnboardingTheme.card)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
