import SwiftUI

struct OnboardingVoiceQuestion: View {
    let data: VoiceQuestionData
    let progress: Double
    let onContinue: () -> Void
    let onSelect: (String, Int) -> Void  // answer text, voiceId

    @State private var selectedText: String? = nil
    @State private var selectedVoiceId: Int? = nil

    var body: some View {
        OnboardingQuestionLayout(
            progress: progress,
            headline: data.headline,
            subheadline: data.subheadline,
            buttonLabel: "Continue",
            onContinue: {
                if let text = selectedText, let voiceId = selectedVoiceId {
                    onSelect(text, voiceId)
                }
                onContinue()
            },
            canContinue: selectedText != nil
        ) {
            ForEach(data.options, id: \.text) { option in
                if data.useQuoteStyle {
                    OnboardingQuoteCard(
                        quote: option.text,
                        isSelected: selectedText == option.text,
                        action: {
                            selectedText = option.text
                            selectedVoiceId = option.voiceId
                        }
                    )
                } else {
                    OnboardingSelectableCard(
                        text: option.text,
                        isSelected: selectedText == option.text,
                        action: {
                            selectedText = option.text
                            selectedVoiceId = option.voiceId
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    OnboardingVoiceQuestion(
        data: .q1_innerVoice,
        progress: 0.3,
        onContinue: {},
        onSelect: { _, _ in }
    )
}
