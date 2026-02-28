import SwiftUI

struct OnboardingVoiceSelection: View {
    let onContinue: () -> Void
    let onSelect: (Int) -> Void
    
    @State private var selectedVoiceId: Int? = nil
    
    // Each quote maps to a voice archetype:
    // 1 = Poetic Insight (Rilke / WeTheUrban)
    // 2 = Rational Clarity (Marcus / Naval)
    // 3 = Gentle Human Presence (Rogers / Brené Brown)
    // 4 = Clear Modern Action (Epictetus / James Clear)
    
    private let quotes: [(text: String, voiceId: Int)] = [
        (
            "Some clarity comes from letting things be unfinished.",
            1  // Rilke - Poetic Insight
        ),
        (
            "If it's not in your control, stop giving it energy.",
            2  // Marcus - Rational Clarity
        ),
        (
            "You can be honest with yourself without being cruel.",
            3  // Rogers - Gentle Human Presence
        ),
        (
            "Limit the decision to what you can do next.",
            4  // Epictetus - Clear Modern Action
        )
    ]
    
    var body: some View {
        OnboardingQuestionLayout(
            progress: 0.7,  // Legacy — not in active flow
            headline: "You're overthinking and stuck in your head.",
            subheadline: "Which advice feels most aligned with you?",
            buttonLabel: "Continue",
            onContinue: {
                if let voiceId = selectedVoiceId {
                    onSelect(voiceId)
                }
                onContinue()
            },
            canContinue: selectedVoiceId != nil
        ) {
            ForEach(quotes, id: \.voiceId) { quote in
                OnboardingQuoteCard(
                    quote: quote.text,
                    isSelected: selectedVoiceId == quote.voiceId,
                    action: { selectedVoiceId = quote.voiceId }
                )
            }
        }
    }
}

#Preview {
    OnboardingVoiceSelection(onContinue: {}, onSelect: { _ in })
}
