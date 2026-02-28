import SwiftUI

struct OnboardingWidgetScreen: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            OnboardingTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                OnboardingProgressBar(progress: 0.8)
                
                Spacer()
                    .frame(height: 20)
                
                // Phone mockup - cropped and faded
                Image("lockscreen-widget-mockup")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 280)
                    // Crop bottom 10-15% by clipping
                    .mask(
                        VStack(spacing: 0) {
                            Rectangle()
                            // Cut off bottom ~12%
                        }
                        .frame(height: 420) // Constrains visible height
                        .frame(maxHeight: .infinity, alignment: .top)
                    )
                    // Fade that starts higher and reaches background before text
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .black, location: 0),
                                .init(color: .black, location: 0.45),
                                .init(color: .clear, location: 0.72)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Increased spacing between phone and headline block (~20px more)
                Spacer()
                    .frame(height: 8)
                
                // Text content - grouped block
                VStack(spacing: 14) { // 12-16px between headline and subheading
                    Text("Always there. Never pushy.")
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(OnboardingTheme.foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text("Your journal lives on your lock screen, ready when you glance.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(OnboardingTheme.muted)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, OnboardingTheme.screenPadding)
                
                Spacer()
            }
            
            OnboardingContinueButton(
                label: "Continue",
                action: onContinue
            )
        }
    }
}

#Preview {
    OnboardingWidgetScreen(onContinue: {})
}
