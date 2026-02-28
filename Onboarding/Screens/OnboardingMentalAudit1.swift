import SwiftUI

struct OnboardingMentalAudit1: View {
    let onContinue: () -> Void
    let onSelect: (String) -> Void
    
    @State private var selected: String? = nil
    
    private let options = [
        "I'm behind where I should be.",
        "Nothing I do ever feels enough.",
        "It's whatever. I'll deal with it later.",
        "I'm doing the best I can right now."
    ]
    
    var body: some View {
        OnboardingQuestionLayout(
            progress: 0.3,  // Legacy — not in active flow
            headline: "Which of these sounds most like your inner voice?",
            subheadline: "",
            buttonLabel: "Continue",
            onContinue: {
                if let selected = selected {
                    onSelect(selected)
                }
                onContinue()
            },
            canContinue: selected != nil
        ) {
            ForEach(options, id: \.self) { option in
                OnboardingSelectableCard(
                    text: option,
                    isSelected: selected == option,
                    action: { selected = option }
                )
            }
        }
    }
}

#Preview {
    OnboardingMentalAudit1(onContinue: {}, onSelect: { _ in })
}
