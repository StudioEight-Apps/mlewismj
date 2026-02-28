import SwiftUI

struct OnboardingComplete: View {
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingCenteredLayout(
            progress: 1.0,  // 100% complete
            buttonLabel: "Start Journaling",
            onContinue: onContinue
        ) {
            VStack(spacing: 0) {
                // Headline
                Text("You're all set.")
                    .font(OnboardingTheme.headlineLarge())
                    .foregroundColor(OnboardingTheme.foreground)
                    .multilineTextAlignment(.center)
                
                // Body
                Text("The more you journal, the more personalized your whispers become. Start your first entry and let Whisper learn your voice.")
                    .font(OnboardingTheme.body())
                    .foregroundColor(OnboardingTheme.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.top, 16)
            }
            .frame(maxWidth: 340)
        }
    }
}

#Preview {
    OnboardingComplete(onContinue: {})
}
