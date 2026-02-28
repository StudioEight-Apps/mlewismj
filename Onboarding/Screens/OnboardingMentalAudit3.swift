import SwiftUI

struct OnboardingMentalAudit3: View {
    let onContinue: () -> Void
    let onSelect: (String) -> Void
    
    @State private var selected: String? = nil
    
    private let options = [
        "I push through and keep going",
        "I shut down and withdraw",
        "I spiral into overthinking",
        "I distract myself until it passes"
    ]
    
    var body: some View {
        OnboardingQuestionLayout(
            progress: 0.5,  // Legacy — not in active flow
            headline: "When stress hits, what do you usually do?",
            subheadline: "No right answers—just patterns.",
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
    OnboardingMentalAudit3(onContinue: {}, onSelect: { _ in })
}

