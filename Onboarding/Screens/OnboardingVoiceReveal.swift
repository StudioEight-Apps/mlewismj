import SwiftUI
import StoreKit

struct OnboardingVoiceReveal: View {
    let archetype: VoiceArchetype
    let onContinue: () -> Void

    // The randomly-selected variation — picked once on appear
    @State private var variation: VoiceArchetype.Variation?

    // Phase control
    @State private var phase: RevealPhase = .loading

    // Loading state
    @State private var loadingProgress: CGFloat = 0
    @State private var loadingStatus: Int = 0

    // Reveal animation state
    @State private var showLabel = false
    @State private var showName = false
    @State private var showShades = false
    @State private var showTagline = false
    @State private var showCards = false

    private enum RevealPhase {
        case loading
        case revealed
    }

    private let loadingMessages = [
        "Reading your answers…",
        "Finding patterns in your responses…",
        "Curating a voice built around you."
    ]

    var body: some View {
        ZStack {
            OnboardingTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingProgressBar(progress: OnboardingScreen.voiceReveal.progress)

                if phase == .loading {
                    loadingView
                } else if let v = variation {
                    revealView(v)
                }
            }

            if phase == .revealed {
                OnboardingContinueButton(label: "Continue", action: onContinue)
            }
        }
        .onAppear {
            // Pick a random variation once — this is what makes each reveal feel unique
            variation = archetype.randomVariation()
            startLoading()
        }
    }

    // MARK: - Loading Phase

    private var loadingView: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Curating your voice\nfrom your answers")
                .font(OnboardingTheme.headlineLarge())
                .foregroundColor(OnboardingTheme.foreground)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Spacing between heading and bar
            Spacer().frame(height: 32)

            VStack(alignment: .trailing, spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(OnboardingTheme.progressTrack)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(OnboardingTheme.accent)
                            .frame(width: geometry.size.width * loadingProgress, height: 6)
                    }
                }
                .frame(height: 6)

                Text("\(Int(loadingProgress * 100))%")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(OnboardingTheme.muted)
                    .monospacedDigit()
            }
            .padding(.horizontal, 48)

            // Spacing between bar and status message
            Spacer().frame(height: 20)

            Text(loadingMessages[loadingStatus])
                .font(OnboardingTheme.body())
                .foregroundColor(OnboardingTheme.muted)
                .animation(.easeInOut(duration: 0.3), value: loadingStatus)
                .id(loadingStatus)

            Spacer()
        }
    }

    // MARK: - Reveal Phase

    private func revealView(_ v: VoiceArchetype.Variation) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 48)

                // "YOUR JOURNAL'S VOICE"
                Text("Your journal's voice")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(OnboardingTheme.muted)
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .opacity(showLabel ? 1 : 0)

                // Archetype name — large serif
                Text(v.name)
                    .font(.system(size: 38, weight: .medium, design: .serif))
                    .foregroundColor(OnboardingTheme.foreground)
                    .padding(.top, 12)
                    .opacity(showName ? 1 : 0)
                    .offset(y: showName ? 0 : 12)
                    .scaleEffect(showName ? 1.0 : 0.92)

                // Gold divider
                Rectangle()
                    .fill(OnboardingTheme.accent)
                    .frame(width: 40, height: 2)
                    .padding(.top, 16)
                    .opacity(showShades ? 1 : 0)

                // "Shades of Writer1, Writer2 & Writer3"
                Text("Shades of \(v.writers[0].name), \(v.writers[1].name) & \(v.writers[2].name)")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(OnboardingTheme.muted)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .lineLimit(2)
                    .padding(.top, 14)
                    .padding(.horizontal, 24)
                    .opacity(showShades ? 1 : 0)
                    .offset(y: showShades ? 0 : 8)

                // Tagline
                Text(v.tagline)
                    .font(OnboardingTheme.body())
                    .foregroundColor(OnboardingTheme.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 16)
                    .padding(.horizontal, 32)
                    .opacity(showTagline ? 1 : 0)

                // Quote mantra cards
                VStack(spacing: 14) {
                    ForEach(v.writers.indices, id: \.self) { index in
                        RevealQuoteCard(writer: v.writers[index])
                            .opacity(showCards ? 1 : 0)
                            .offset(y: showCards ? 0 : 16)
                            .animation(
                                .easeOut(duration: 0.5).delay(Double(index) * 0.15),
                                value: showCards
                            )
                    }
                }
                .padding(.top, 32)
                .padding(.horizontal, OnboardingTheme.screenPadding)

                // Reserve space for button
                Spacer().frame(height: 140)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Loading Animation

    private func startLoading() {
        let totalDuration: Double = 5.0
        let interval: Double = 0.05
        let increment: CGFloat = CGFloat(interval / totalDuration)

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if loadingProgress < 1.0 {
                loadingProgress = min(loadingProgress + increment, 1.0)

                if loadingProgress >= 0.60 && loadingStatus < 2 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        loadingStatus = 2
                    }
                } else if loadingProgress >= 0.30 && loadingStatus < 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        loadingStatus = 1
                    }
                }
            } else {
                timer.invalidate()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    // Track voice reveal
                    AnalyticsService.shared.trackOnboardingVoiceRevealed(
                        voiceId: archetype.voiceId,
                        archetypeName: variation?.name ?? "unknown"
                    )

                    withAnimation(.easeInOut(duration: 0.3)) {
                        phase = .revealed
                    }

                    // Stagger the reveal animations
                    withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                        showLabel = true
                    }
                    withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                        showName = true
                    }
                    withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                        showShades = true
                    }
                    withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
                        showTagline = true
                    }
                    withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                        showCards = true
                    }

                    // Request App Store review after reveal animations complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Quote Card for Reveal

struct RevealQuoteCard: View {
    let writer: VoiceArchetype.WriterReference

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\"\(writer.quote)\"")
                .font(.system(size: 16, weight: .regular, design: .serif))
                .italic()
                .foregroundColor(OnboardingTheme.foreground)
                .lineSpacing(5)

            HStack(spacing: 0) {
                Rectangle()
                    .fill(OnboardingTheme.accent)
                    .frame(width: 16, height: 1.5)
                    .padding(.trailing, 8)

                Text(writer.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(OnboardingTheme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(OnboardingTheme.card)
        )
    }
}


#Preview {
    OnboardingVoiceReveal(
        archetype: .commander,
        onContinue: {}
    )
}
