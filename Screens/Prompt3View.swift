import SwiftUI

struct Prompt3View: View {
    @State private var responseText: String = ""
    @State private var currentQuestion: String = ""
    @State private var showTextEditor = false
    @FocusState private var isInputFocused: Bool
    @State private var isButtonPressed = false
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
    let mood: String
    let prompt1: String
    let prompt2: String
    let question1: String
    let question2: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("Prompt 3 of 3")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(colors.promptCapsuleText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(colors.promptCapsule))
                    .zIndex(1)
                    .offset(y: 12)

                Text(currentQuestion)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(colors.questionCard)
                            .shadow(color: colors.questionCardShadow, radius: 8, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(colors.cardBorder, lineWidth: 0.5)
                            )
                    )
                    .padding(.horizontal, 24)
            }
            .padding(.top, 60)

            Button(action: { showTextEditor = true }) {
                HStack {
                    Text(responseText.isEmpty ? "Write as much or as little as you'd like..." : responseText)
                        .font(.system(size: 16, weight: .regular))
                        .italic(responseText.isEmpty)
                        .foregroundColor(responseText.isEmpty ? colors.placeholder : colors.primaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(responseText.isEmpty ? 0.8 : 1.0)
                    Spacer()
                }
                .padding(16)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colors.questionCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isInputFocused ? colors.inputFocusBorder : colors.inputBorder, lineWidth: 1.5)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .animation(.easeOut(duration: 0.25), value: isInputFocused)

            Spacer()

            NavigationLink(destination: LoadingView(
                mood: mood,
                response1: prompt1,
                response2: prompt2,
                response3: responseText,
                questions: [question1, question2, currentQuestion]
            )) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colors.buttonText)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(colors.buttonBackground)
                    )
                    .scaleEffect(isButtonPressed ? 0.97 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            withAnimation(.easeOut(duration: 0.1)) { isButtonPressed = true }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.1)) { isButtonPressed = false }
                    }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(colors.secondaryBackground)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        .onAppear {
            currentQuestion = PromptQuestionBank.getQuestion(for: mood, phase: 3)
        }
        .sheet(isPresented: $showTextEditor) {
            TextEditorView(text: $responseText, question: currentQuestion)
                .onDisappear {
                    isInputFocused = !responseText.isEmpty
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isInputFocused = false
                    }
                }
        }
    }
}
