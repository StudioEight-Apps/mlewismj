import SwiftUI

struct OnboardingIntro1: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            OnboardingTheme.background.ignoresSafeArea()

            GeometryReader { geo in
                let screenH = geo.size.height
                // Scale mockup height: ~55% of screen on Pro Max, capped for SE
                let mockupH = min(screenH * 0.52, 420)

                VStack(spacing: 0) {
                    OnboardingProgressBar(progress: OnboardingScreen.intro1.progress)

                    Spacer()
                        .frame(height: 12)

                    // Phone mockup - cropped and faded
                    Image("lockscreen-widget-mockup")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 280)
                        // Crop bottom by clipping — responsive height
                        .mask(
                            VStack(spacing: 0) {
                                Rectangle()
                            }
                            .frame(height: mockupH)
                            .frame(maxHeight: .infinity, alignment: .top)
                        )
                        // Fade that starts higher and reaches background before text
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .black, location: 0.40),
                                    .init(color: .clear, location: 0.68)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Text content - grouped block
                    VStack(spacing: 14) {
                        Text("Most journals listen.\nThis one responds.")
                            .font(OnboardingTheme.headlineLarge())
                            .foregroundColor(OnboardingTheme.foreground)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        Text("Whisper learns you as you journal and speaks back throughout the day on your lock and home screen.")
                            .font(OnboardingTheme.body())
                            .foregroundColor(OnboardingTheme.muted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)

                    Spacer()
                }
            }

            OnboardingContinueButton(
                label: "Continue",
                action: onContinue
            )
        }
    }
}

#Preview {
    OnboardingIntro1(onContinue: {})
}
