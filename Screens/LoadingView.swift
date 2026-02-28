import SwiftUI

struct LoadingView: View {
    var mood: String
    var response1: String
    var response2: String
    var response3: String
    var questions: [String]
    var journalType: JournalType = .guided

    @State private var isLoadingComplete = false
    @State private var generatedMantra: String = ""

    // Convenience initializer for free journal
    init(mood: String, freeJournalText: String) {
        self.mood = mood
        self.response1 = freeJournalText
        self.response2 = ""
        self.response3 = ""
        self.questions = ["What's on your mind?"]
        self.journalType = .free
    }

    // Original initializer for guided journal
    init(mood: String, response1: String, response2: String, response3: String, questions: [String] = []) {
        self.mood = mood
        self.response1 = response1
        self.response2 = response2
        self.response3 = response3
        self.questions = questions
        self.journalType = .guided
    }

    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    var body: some View {
        ZStack {
            colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    ThreeDotsLoader()

                    Text("Finding the right words...")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(colors.primaryText)
                        .opacity(0.7)
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        // Modern NavigationStack API — closure evaluates WHEN isPresented becomes true
        // so generatedMantra is guaranteed to have the real value, not stale ""
        .navigationDestination(isPresented: $isLoadingComplete) {
            MantraSummaryView(
                mood: mood,
                prompt1: response1,
                prompt2: response2,
                prompt3: response3,
                mantra: generatedMantra,
                journalType: journalType,
                promptQuestions: questions
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                MantraGenerator.generateMantra(
                    mood: mood,
                    response1: response1,
                    response2: response2,
                    response3: response3,
                    journalType: journalType
                ) { result in
                    generatedMantra = result ?? "Breathe. You are here now."
                    isLoadingComplete = true
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}

// Custom three-dot loading animation
struct ThreeDotsLoader: View {
    @State private var animationIndex = 0

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color(hex: "#C4A574"))
                    .frame(width: 10, height: 10)
                    .scaleEffect(animationIndex == index ? 1.2 : 0.8)
                    .opacity(animationIndex == index ? 1.0 : 0.4)
                    .animation(.easeInOut(duration: 0.6), value: animationIndex)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation {
                animationIndex = (animationIndex + 1) % 3
            }
        }
    }
}
