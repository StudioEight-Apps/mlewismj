import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Onboarding Screen Enum

enum OnboardingScreen: Int, CaseIterable {
    case intro1 = 0
    case voiceContext          // "Let's set up your journal's voice"
    case q1_innerVoice
    case q2_selfTalk
    case q3_stressResponse
    case q4_hardestPart
    case q5_trustAdvice
    case q6_endOfDay
    case q7_quoteResonance
    case q8_overthinking
    case voiceReveal           // "Shades of..." reveal
    case authScreen
    case complete

    var progress: Double {
        Double(self.rawValue + 1) / Double(OnboardingScreen.allCases.count)
    }

    /// Returns the question data for question screens, nil for non-question screens
    var questionData: VoiceQuestionData? {
        switch self {
        case .q1_innerVoice: return .q1_innerVoice
        case .q2_selfTalk: return .q2_selfTalk
        case .q3_stressResponse: return .q3_stressResponse
        case .q4_hardestPart: return .q4_hardestPart
        case .q5_trustAdvice: return .q5_trustAdvice
        case .q6_endOfDay: return .q6_endOfDay
        case .q7_quoteResonance: return .q7_quoteResonance
        case .q8_overthinking: return .q8_overthinking
        default: return nil
        }
    }
}


// MARK: - Onboarding State

class OnboardingState: ObservableObject {
    @Published var currentScreen: OnboardingScreen = .intro1

    // Voice archetype scoring — tracks points per voice ID (1-4)
    @Published var scores: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0]

    // All question answers stored for Firebase
    @Published var answers: [String: String] = [:]

    /// The winning voice ID based on cumulative scores across all 8 questions
    var voiceId: Int {
        let topVoice = scores.max(by: { $0.value < $1.value })?.key ?? 1
        return topVoice
    }

    /// The full archetype result for the reveal screen
    var archetype: VoiceArchetype {
        VoiceArchetype.archetype(for: voiceId)
    }

    /// Record an answer and update the score for the corresponding voice
    func recordAnswer(key: String, answer: String, voiceId: Int) {
        answers[key] = answer
        // Weight Q7 (quote_resonance) and Q8 (overthinking) double —
        // they're direct voice preference signals vs understanding questions
        let weight = (key == "quote_resonance" || key == "overthinking") ? 2 : 1
        scores[voiceId, default: 0] += weight
        AnalyticsService.shared.trackOnboardingQuestionAnswered(questionKey: key, selectedVoiceId: voiceId, stepIndex: currentScreen.rawValue)
    }

    // MARK: - Navigation

    func next() {
        guard let nextScreen = OnboardingScreen(rawValue: currentScreen.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: OnboardingTheme.transitionDuration)) {
            currentScreen = nextScreen
        }
        // Track funnel step
        AnalyticsService.shared.trackOnboardingScreenViewed(screen: "\(nextScreen)", stepIndex: nextScreen.rawValue)
        OnboardingFunnelLogger.shared.logStep(step: "\(nextScreen)", stepIndex: nextScreen.rawValue)
    }

    func goTo(_ screen: OnboardingScreen) {
        withAnimation(.easeInOut(duration: OnboardingTheme.transitionDuration)) {
            currentScreen = screen
        }
        AnalyticsService.shared.trackOnboardingScreenViewed(screen: "\(screen)", stepIndex: screen.rawValue)
        OnboardingFunnelLogger.shared.logStep(step: "\(screen)", stepIndex: screen.rawValue)
    }

    // MARK: - Save to Firebase + UserDefaults

    func saveOnboardingData(userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let finalVoiceId = voiceId

        // Convert Int keys to String keys for Firestore compatibility
        var scoreStrings: [String: Int] = [:]
        for (key, value) in scores {
            scoreStrings[String(key)] = value
        }

        let data: [String: Any] = [
            "voice_id": finalVoiceId,
            "voice_archetype": archetype.randomVariation().name,
            "onboarding_answers": answers,
            "onboarding_scores": scoreStrings,
            "onboarding_completed_at": Timestamp(date: Date())
        ]

        db.collection("users").document(userId).setData(data, merge: true) { error in
            if let error = error {
                print("❌ Failed to save onboarding data: \(error.localizedDescription)")
                completion(false)
            } else {
                UserDefaults.standard.set(finalVoiceId, forKey: "voice_id")
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                print("✅ Onboarding data saved - voice_id: \(finalVoiceId)")
                completion(true)
            }
        }
    }
}


// MARK: - Onboarding Coordinator

struct OnboardingCoordinatorNew: View {
    @StateObject private var state = OnboardingState()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            OnboardingTheme.background.ignoresSafeArea()

            // Screen content
            Group {
                switch state.currentScreen {
                case .intro1:
                    OnboardingIntro1(onContinue: state.next)

                case .voiceContext:
                    OnboardingVoiceContext(onContinue: state.next)

                // All 8 question screens — same view, different data
                case .q1_innerVoice, .q2_selfTalk, .q3_stressResponse,
                     .q4_hardestPart, .q5_trustAdvice, .q6_endOfDay,
                     .q7_quoteResonance, .q8_overthinking:
                    if let data = state.currentScreen.questionData {
                        OnboardingVoiceQuestion(
                            data: data,
                            progress: state.currentScreen.progress,
                            onContinue: state.next,
                            onSelect: { answer, voiceId in
                                state.recordAnswer(key: data.key, answer: answer, voiceId: voiceId)
                            }
                        )
                        .id(state.currentScreen)  // Force view recreation per screen
                    }

                case .voiceReveal:
                    OnboardingVoiceReveal(
                        archetype: state.archetype,
                        onContinue: { state.goTo(.authScreen) }
                    )

                case .authScreen:
                    OnboardingAuthScreen(
                        state: state,
                        onComplete: { handleAuthComplete() }
                    )

                case .complete:
                    OnboardingComplete(onContinue: { finishOnboarding() })
                }
            }
            .transition(.opacity)
        }
        .onAppear {
            // Track first screen + start funnel session
            OnboardingFunnelLogger.shared.resetSession()
            AnalyticsService.shared.trackOnboardingScreenViewed(screen: "intro1", stepIndex: 0)
            OnboardingFunnelLogger.shared.logStep(step: "intro1", stepIndex: 0)
        }
    }

    private func handleAuthComplete() {
        // Attach userId to funnel session
        if let userId = authViewModel.user?.uid {
            OnboardingFunnelLogger.shared.attachUserId(userId)
            AnalyticsService.shared.setUserId(userId)
        }
        state.next()
    }

    private func finishOnboarding() {
        // Track completion
        AnalyticsService.shared.trackOnboardingCompleted(voiceId: state.voiceId)
    }
}


// MARK: - Preview

#Preview {
    OnboardingCoordinatorNew()
        .environmentObject(AuthViewModel.shared)
}
