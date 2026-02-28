import SwiftUI

struct OnboardingVoiceContext: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingCenteredLayout(
            progress: OnboardingScreen.voiceContext.progress,
            onContinue: onContinue
        ) {
            VStack(spacing: 0) {
                // Headline
                Text("Let's set up your\njournal's voice.")
                    .font(OnboardingTheme.headlineLarge())
                    .foregroundColor(OnboardingTheme.foreground)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Body
                Text("Everyone connects with words differently. A few quick questions to find the style that resonates with you.")
                    .font(OnboardingTheme.body())
                    .foregroundColor(OnboardingTheme.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.top, 32)
            }
            .frame(maxWidth: 340)
        }
    }
}

#Preview {
    OnboardingVoiceContext(onContinue: {})
}
