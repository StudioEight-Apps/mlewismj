import SwiftUI

struct OnboardingMentalAudit2: View {
    let onContinue: () -> Void
    let onSelect: (String) -> Void
    
    @State private var selected: String? = nil
    
    private let options = [
        "I feel clearer and more grounded",
        "I push myself but feel worn down",
        "I get stuck overthinking",
        "I shut down or avoid it"
    ]
    
    var body: some View {
        OnboardingQuestionLayout(
            progress: 0.4,  // Legacy — not in active flow
            headline: "After that thought shows up, what usually happens next?",
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
    OnboardingMentalAudit2(onContinue: {}, onSelect: { _ in })
}
